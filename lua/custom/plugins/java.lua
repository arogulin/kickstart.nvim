-- Java: jdtls (Eclipse JDT language server) + DAP, via nvim-jdtls.
--
-- Unlike the Python LSPs (pyright/ruff), jdtls is NOT added to the `servers`
-- table in init.lua and is not started by `vim.lsp.enable`. It needs a unique
-- workspace data dir per project and must be (re)started per buffer, so it is
-- launched from a FileType autocmd by `nvim-jdtls` instead.
--
-- The Java debugger is not a standalone DAP adapter like debugpy: the mason
-- packages `java-debug-adapter` and `java-test` are JDT bundles loaded into
-- jdtls via `init_options.bundles`. `require('jdtls').setup_dap()` then
-- registers the `java` dap adapter, which reuses the dap-ui listeners already
-- wired up in debug.lua. The three mason packages (jdtls, java-debug-adapter,
-- java-test) are in the `ensure_installed` list in init.lua.
--
-- Requires a JDK 21+ on PATH (jdtls runs on it; the project itself can target
-- an older Java via JAVA_HOME / runtimes configuration).
--
-- Lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by that
-- directory's init.lua loader.

local function gh(repo) return 'https://github.com/' .. repo end

vim.pack.add { gh 'mfussenegger/nvim-jdtls' }

local mason = vim.fn.stdpath 'data' .. '/mason'

-- Remote-attach DAP config for debugging tests run via Gradle. nvim-jdtls's
-- direct test runner (<leader>dn / <leader>dN) launches the JVM itself with the
-- flattened Eclipse project classpath, which does NOT match a custom source
-- set's Gradle classpath (e.g. fudge's `integrationTest` = main.output +
-- test.output + integration-test deps). Such tests then fail to bootstrap Spring
-- under the direct runner even though they pass under Gradle. Instead, run them
-- with Gradle's exact environment and attach:
--   ./gradlew integrationTest --tests "<FQN>.<method>" --debug-jvm
-- which suspends the test JVM listening on :5005, then pick this config via
-- <leader>dc. Registered once at module load; the `java` adapter itself is set
-- up per-buffer by setup_dap in on_attach below.
local dap = require 'dap'
dap.configurations.java = dap.configurations.java or {}
table.insert(dap.configurations.java, {
  type = 'java',
  request = 'attach',
  name = 'Attach to JVM on :5005 (gradle --debug-jvm)',
  hostName = '127.0.0.1',
  port = 5005,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'java',
  group = vim.api.nvim_create_augroup('custom-jdtls', { clear = true }),
  callback = function(event)
    -- Detect the project root; bail on a stray .java file with no project.
    local root_dir = vim.fs.root(event.buf, { 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', '.git' })
    if not root_dir then return end

    -- jdtls requires a unique workspace data dir per project. Derive it from the
    -- FULL root path, not just the basename: two projects with the same folder
    -- name in different parents (~/work/a/service vs ~/work/b/service) would
    -- otherwise share one workspace dir and corrupt each other's index. Encode
    -- the absolute path into a single filesystem-safe segment.
    local key = vim.fn.fnamemodify(root_dir, ':p'):gsub('[/\\:]', '%%')
    local workspace_dir = vim.fn.stdpath 'data' .. '/jdtls-workspace/' .. key

    -- DAP + test bundles loaded into jdtls.
    local bundles =
      vim.fn.glob(mason .. '/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar', true, true)
    vim.list_extend(bundles, vim.fn.glob(mason .. '/packages/java-test/extension/server/*.jar', true, true))

    local jdtls = require 'jdtls'
    jdtls.start_or_attach {
      -- mason's jdtls launcher resolves the equinox jar and OS config dir itself.
      cmd = { mason .. '/bin/jdtls', '-data', workspace_dir },
      root_dir = root_dir,
      init_options = { bundles = bundles },
      on_attach = function()
        -- Register the `java` dap adapter + launch configs (main classes, tests).
        jdtls.setup_dap { hotcodereplace = 'auto' }
      end,
    }

    -- Buffer-local test-debug keymaps (Java only). Bound here in the FileType
    -- callback — which always fires per Java buffer — rather than in on_attach,
    -- because on_attach is unreliable when a buffer attaches to an
    -- already-running jdtls client (so the second project file would get no
    -- maps). These START a JUnit test under the debugger via the java-test
    -- bundle (computing its classpath and runner); the generic <leader>d* maps
    -- in debug.lua then drive the running session (<leader>dc continue, etc.).
    local function map(lhs, rhs, desc) vim.keymap.set('n', lhs, rhs, { buffer = event.buf, desc = desc }) end
    map('<leader>dn', jdtls.test_nearest_method, 'Debug Nearest test method')
    map('<leader>dN', jdtls.test_class, 'Debug test Class')
  end,
})
