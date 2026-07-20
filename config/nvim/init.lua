-- Detect Python path dynamically
local function find_python()
  -- Check for miniconda/conda
  local conda = os.getenv("CONDA_PREFIX") or (os.getenv("HOME") .. "/miniconda3")
  local conda_py = conda .. "/bin/python"
  if vim.fn.executable(conda_py) == 1 then return conda_py end
  -- Fallback: system python3
  local sys_py = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python3"
  return sys_py
end

-- Detect Node path dynamically
local function find_node()
  -- Check NVM
  local nvm_dir = os.getenv("NVM_DIR") or (os.getenv("HOME") .. "/.nvm")
  -- Try to find latest node version
  local handle = io.popen("ls " .. nvm_dir .. "/versions/node/ 2>/dev/null | sort -V | tail -1")
  if handle then
    local result = handle:read("*a"):gsub("%s+", "")
    handle:close()
    if result ~= "" then
      return nvm_dir .. "/versions/node/" .. result .. "/bin"
    end
  end
  -- Fallback: system node
  local node_path = vim.fn.exepath("node")
  if node_path ~= "" then
    return vim.fn.fnamemodify(node_path, ":h")
  end
  return nil
end

-- Set up PATH for Node (Mason pyright etc. need it)
local node_bin = find_node()
if node_bin then
  vim.env.PATH = node_bin .. ":" .. vim.env.PATH
end

-- Set Python provider
vim.g.python3_host_prog = find_python()

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
