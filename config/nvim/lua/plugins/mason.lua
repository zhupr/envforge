-- Mason: registry access behind restricted networks.
-- Symptom: with the default providers (registry-api + client) an unreachable
-- api.mason-registry.dev makes get_latest_release hang and :MasonUpdate never
-- returns. Set MASON_RESTRICTED=1 (or DOTFILES_RESTRICTED_NETWORK=1) to fall
-- back to the git-less client provider only.
return {
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      if vim.env.MASON_RESTRICTED == "1" or vim.env.DOTFILES_RESTRICTED_NETWORK == "1" then
        opts.providers = { "mason.providers.client" }
      end
    end,
  },
}
