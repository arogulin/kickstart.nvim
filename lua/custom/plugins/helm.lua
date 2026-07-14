-- Helm / gotmpl syntax highlighting.
--
-- Helm chart templates (chart/templates/*.yaml, *.tpl) and helmfile *.gotmpl
-- files are YAML with embedded Go template syntax ({{ ... }}). Neovim detects
-- them as `yaml`, and the yaml treesitter parser errors on the `{{ }}`, so they
-- render mostly unhighlighted. Fix in two native steps (no plugin):
--
--   1. Detect these paths as filetype `helm` instead of `yaml`.
--   2. Map the `helm` filetype to the `gotmpl` treesitter parser. The FileType
--      auto-attach autocmd in init.lua then resolves helm -> gotmpl via
--      vim.treesitter.language.get_lang, auto-installs the gotmpl parser on
--      first open, and starts it.
--
-- Trade-off: a `helm` buffer is highlighted as Go-template, not YAML, so the
-- YAML structure itself is plain text while all template constructs light up.
-- This is the standard pragmatic result for Helm; a single parser can't cleanly
-- highlight both layers.
--
-- Lives in ~/.config/nvim/lua/custom/plugins/ and is `require`d by that
-- directory's init.lua loader (which runs after the treesitter setup, so the
-- auto-attach autocmd already exists when this registration happens).

-- Route the `helm` filetype to the `gotmpl` parser.
vim.treesitter.language.register('gotmpl', 'helm')

-- Detect Helm template files as `helm`. Plain chart files (Chart.yaml,
-- values.yaml at the chart root) are intentionally NOT matched here - they stay
-- `yaml`. Only files under a templates/ dir and *.gotmpl are templated.
vim.filetype.add {
  extension = {
    gotmpl = 'helm',
  },
  pattern = {
    ['.*/templates/.*%.ya?ml'] = 'helm',
    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/templates/.*%.txt'] = 'helm', -- NOTES.txt
  },
}
