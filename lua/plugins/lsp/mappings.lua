local lsp = vim.lsp.buf
local telescope = require('telescope.builtin')

local M = {}

local function diagnostic_goto(next, severity)
  local go_to = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function() go_to { severity = severity } end
end

local mappings = {
  -- Movement
  ['gd'] = { lsp.definition, 'Goto Definition' },
  ['gr'] = { telescope.lsp_references, 'Goto References' },
  ['<leader>D'] = { lsp.type_definition, 'Type Definition' },
  ['gI'] = { lsp.implementation, 'Goto Implementation' },
  -- ['<leader>dl'] = { vim.diagnostic.setloclist, 'Show diagnostics in quickfix' },
  -- ['<leader>dp'] = { vim.diagnostic.setqflist, 'Show all diagnostics in quickfix' },
  ['<leader>dl'] = { '<cmd>TroubleToggle document_diagnostics<cr>', 'Document Diagnostics (Trouble)' },
  ['<leader>dp'] = { '<cmd>TroubleToggle workspace_diagnostics<cr>', 'Workspace Diagnostics (Trouble)' },
  [']d'] = { vim.diagnostic.goto_next, 'Goto Next Diagnostic' },
  ['[d'] = { vim.diagnostic.goto_prev, 'Goto Previous Diagnostic' },
  [']e'] = { diagnostic_goto(true, 'ERROR'), 'Goto Next Error' },
  ['[e'] = { diagnostic_goto(false, 'ERROR'), 'Goto Previous Error' },
  [']w'] = { diagnostic_goto(true, 'WARNING'), 'Goto Next Warning' },
  ['[w'] = { diagnostic_goto(false, 'WARNING'), 'Goto Previous Warning' },

  -- Actions
  ['K'] = { lsp.hover, 'Hover Documentation' },
  ['<leader>k'] = { vim.diagnostic.open_float, 'Open diag float' },
  ['<leader>rn'] = { lsp.rename, 'Rename' },
  ['<leader>ca'] = { lsp.code_action, 'Code Action' },
  ['<leader>ds'] = { telescope.lsp_document_symbols, 'Document Symbols' },
  ['<leader>ws'] = { telescope.lsp_dynamic_workspace_symbols, 'Workspace Symbols' },
  ['gK'] = { vim.lsp.buf.signature_help, 'Signature Documentation' },

  -- Less used
  ['gD'] = { lsp.declaration, 'Goto Declaration' },
  ['<leader>wa'] = { lsp.add_workspace_folder, 'Workspace Add Folder' },
  ['<leader>wr'] = { lsp.remove_workspace_folder, 'Workspace Remove Folder' },
  ['<leader>wl'] = { function() print(vim.inspect(lsp.list_workspace_folders())) end, 'Workspace List Folders' },
}

function M.on_attach(client, bufnr)
  if client.name == 'tsserver' then
    local ts = require('typescript')
    mappings['<leader>tO'] = { ts.actions.organizeImports, 'Organize Imports (ts)' }
    mappings['<leader>tM'] = { ts.actions.addMissingImports, 'Add Missing Imports (ts)' }
    mappings['<leader>tU'] = { ts.actions.removeUnused, 'Remove Unused Imports (ts)' }
    mappings['<leader>tR'] = { function() ts.renameFile() end, 'Rename File (ts)' }
  end

  if client.name == 'ruff_lsp' then
    client.server_capabilities.hoverProvider = false
    mappings['<leader>tO'] =
      { function() vim.lsp.buf.execute_command { command = 'organizeImports' } end, 'Organize Imports (ruff)' }
    mappings['<leader>tM'] =
      { function() vim.lsp.buf.execute_command { command = 'addMissingImports' } end, 'Add Missing Imports (ruff)' }
    mappings['<leader>tU'] =
      { function() vim.lsp.buf.execute_command { command = 'removeUnused' } end, 'Remove Unused Imports (ruff)' }
    mappings['<leader>tR'] =
      { function() vim.lsp.buf.execute_command { command = 'renameFile' } end, 'Rename File (ruff)' }
  end

  for k, v in pairs(mappings) do
    require('utils').map('n', k, v[1], { buffer = bufnr, desc = 'LSP: ' .. v[2] })
  end
end

return M
