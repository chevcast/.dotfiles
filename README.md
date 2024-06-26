# CatDadCode .dotfiles

This is my personal development environment. You are welcome to use it or borrow
from it. I'm doing my best to keep all of it as portable as possible, but I make
no guarantees. If you find any issues please feel free to submit a PR or open a
Github issue.

## Try it out with Docker

My full development environment is about 2.22gb in size. The image contains almost
everything I'd ever need for nearly any app I'm working on. Most folks wanting to
try it out are likely just looking for my Neovim setup. So, I have created a
slimmed down Alpine image that is 300.52mb in size. It contains only what is needed
to run my full Neovim setup and nothing extra.

### My full development environment image (2.22gb)

#### `docker run -it catdadcode/devenv`

### Alpine Neovim image (300.52mb)

#### `docker run -it catdadcode/nvim`

> You can even edit your own files with my Neovim setup by mounting a volume to the
> container and specifying the path for Neovim to open.
>
> `docker run -itv /path/to/your/files:/yourfiles catdadcode/nvim /yourfiles`

## Installation

1. Clone the repository into a place of your choosing.

   ```sh
   git clone git@github.com:catdadcode/.dotfiles.git
   ```

2. Run the install script.

   > Note that the install script does NOT automatically back up any existing
   > configuration files. Run at your own risk. If you want to try out the setup
   > before installing then see above for how to run the setup in a Docker container.

   ```sh
   cd .dotfiles && install.sh
   ```

3. ???

4. Profit!

## What's Included

- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/)
- [Bun](https://bun.sh)
- [Dotnet SDK](https://dotnet.microsoft.com/en-us/download)
- [CMake](https://cmake.org/)
- [fd](https://github.com/sharkdp/fd)
- [Git](https://git-scm.com/)
- [Github CLI](https://cli.github.com/)
- [Golang](https://go.dev/doc/install)
- [Homebrew](https://docs.brew.sh/Homebrew-on-Linux)
- [Lazygit](https://github.com/jesseduffield/lazygit#readme)
- [Lua](https://www.lua.org/download.html)
- [Markdown Preview](https://github.com/iamcco/markdown-preview.nvim#readme)
- [Neovim](https://neovim.io/)
- [Oh My ZSH](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k#readme)
- [Python](https://www.python.org/downloads/)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [Volta](https://volta.sh/)
- [Wezterm](https://wezfurlong.org/wezterm/)
- [ZSH](https://www.zsh.org/)
- [Zsh Vi Mode](https://github.com/jeffreytse/zsh-vi-mode#readme)

### Neovim Plugin Manager

- [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- [LazyVim/starter](https://github.com/LazyVim/starter)

### Neovim Plugins (117)
- [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim.git)
- [SchemaStore.nvim](https://github.com/b0o/SchemaStore.nvim.git)
- [bufferline.nvim](https://github.com/akinsho/bufferline.nvim.git)
- [catppuccin](https://github.com/catppuccin/nvim.git)
- [cellular-automaton.nvim](https://github.com/eandrju/cellular-automaton.nvim.git)
- [clangd_extensions.nvim](https://github.com/p00f/clangd_extensions.nvim.git)
- [cmake-tools.nvim](https://github.com/Civitasv/cmake-tools.nvim.git)
- [cmp-buffer](https://github.com/hrsh7th/cmp-buffer.git)
- [cmp-emoji](https://github.com/hrsh7th/cmp-emoji.git)
- [cmp-git](https://github.com/petertriho/cmp-git.git)
- [cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp.git)
- [cmp-path](https://github.com/hrsh7th/cmp-path.git)
- [codeium.nvim](https://github.com/Exafunction/codeium.nvim.git)
- [conform.nvim](https://github.com/stevearc/conform.nvim.git)
- [copilot-cmp](https://github.com/zbirenbaum/copilot-cmp.git)
- [copilot.lua](https://github.com/zbirenbaum/copilot.lua.git)
- [crates.nvim](https://github.com/Saecki/crates.nvim.git)
- [dashboard-nvim](https://github.com/nvimdev/dashboard-nvim.git)
- [dial.nvim](https://github.com/monaqa/dial.nvim.git)
- [edgy.nvim](https://github.com/folke/edgy.nvim.git)
- [firenvim](https://github.com/glacambre/firenvim.git)
- [flash.nvim](https://github.com/folke/flash.nvim.git)
- [friendly-snippets](https://github.com/rafamadriz/friendly-snippets.git)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua.git)
- [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim.git)
- [glow.nvim](https://github.com/ellisonleao/glow.nvim.git)
- [gruvbox.nvim](https://github.com/ellisonleao/gruvbox.nvim.git)
- [guess-indent.nvim](https://github.com/NMAC427/guess-indent.nvim.git)
- [headlines.nvim](https://github.com/lukas-reineke/headlines.nvim.git)
- [inc-rename.nvim](https://github.com/smjonas/inc-rename.nvim.git)
- [indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim.git)
- [kube-utils-nvim](https://github.com/h4ckm1n-dev/kube-utils-nvim.git)
- [lazydev.nvim](https://github.com/folke/lazydev.nvim.git)
- [lua-utils.nvim](https://github.com/nvim-neorg/lua-utils.nvim.git)
- [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim.git)
- [luvit-meta](https://github.com/Bilal2453/luvit-meta.git)
- [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim.git)
- [markdown.nvim](https://github.com/MeanderingProgrammer/markdown.nvim.git)
- [mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim.git)
- [mason-nvim-dap.nvim](https://github.com/jay-babu/mason-nvim-dap.nvim.git)
- [mason.nvim](https://github.com/williamboman/mason.nvim.git)
- [mini.ai](https://github.com/echasnovski/mini.ai.git)
- [mini.animate](https://github.com/echasnovski/mini.animate.git)
- [mini.files](https://github.com/echasnovski/mini.files.git)
- [mini.hipatterns](https://github.com/echasnovski/mini.hipatterns.git)
- [mini.surround](https://github.com/echasnovski/mini.surround.git)
- [neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim.git)
- [neoconf.nvim](https://github.com/folke/neoconf.nvim.git)
- [neogen](https://github.com/danymat/neogen.git)
- [neorg](https://github.com/nvim-neorg/neorg.git)
- [neotest](https://github.com/nvim-neotest/neotest.git)
- [neotest-elixir](https://github.com/jfpedroza/neotest-elixir.git)
- [neotest-golang](https://github.com/fredrikaverpil/neotest-golang.git)
- [neotest-playwright](https://github.com/thenbe/neotest-playwright.git)
- [neotest-plenary](https://github.com/nvim-neotest/neotest-plenary.git)
- [neotest-python](https://github.com/nvim-neotest/neotest-python.git)
- [neotest-vitest](https://github.com/marilari88/neotest-vitest.git)
- [noice.nvim](https://github.com/folke/noice.nvim.git)
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim.git)
- [nvim-autopairs](https://github.com/windwp/nvim-autopairs.git)
- [nvim-cmp](https://github.com/hrsh7th/nvim-cmp.git)
- [nvim-dap](https://github.com/mfussenegger/nvim-dap.git)
- [nvim-dap-go](https://github.com/leoluz/nvim-dap-go.git)
- [nvim-dap-python](https://github.com/mfussenegger/nvim-dap-python.git)
- [nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui.git)
- [nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text.git)
- [nvim-ghost.nvim](https://github.com/subnut/nvim-ghost.nvim.git)
- [nvim-hlslens](https://github.com/kevinhwang91/nvim-hlslens.git)
- [nvim-jdtls](https://github.com/mfussenegger/nvim-jdtls.git)
- [nvim-lint](https://github.com/mfussenegger/nvim-lint.git)
- [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig.git)
- [nvim-nio](https://github.com/nvim-neotest/nvim-nio.git)
- [nvim-notify](https://github.com/rcarriga/nvim-notify.git)
- [nvim-scrollbar](https://github.com/petertriho/nvim-scrollbar.git)
- [nvim-snippets](https://github.com/garymjr/nvim-snippets.git)
- [nvim-spectre](https://github.com/nvim-pack/nvim-spectre.git)
- [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter.git)
- [nvim-treesitter-context](https://github.com/nvim-treesitter/nvim-treesitter-context.git)
- [nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects.git)
- [nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag.git)
- [nvim-web-devicons](https://github.com/nvim-tree/nvim-web-devicons.git)
- [octo.nvim](https://github.com/pwntester/octo.nvim.git)
- [oil.nvim](https://github.com/stevearc/oil.nvim.git)
- [one-small-step-for-vimkind](https://github.com/jbyuki/one-small-step-for-vimkind.git)
- [pathlib.nvim](https://github.com/pysan3/pathlib.nvim.git)
- [persistence.nvim](https://github.com/folke/persistence.nvim.git)
- [playtime.nvim](https://github.com/rktjmp/playtime.nvim.git)
- [plenary.nvim](https://github.com/nvim-lua/plenary.nvim.git)
- [precognition.nvim](https://github.com/tris203/precognition.nvim.git)
- [project.nvim](https://github.com/ahmedkhalf/project.nvim.git)
- [rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim.git)
- [rainbow_csv](https://github.com/mechatroner/rainbow_csv.git)
- [refactoring.nvim](https://github.com/ThePrimeagen/refactoring.nvim.git)
- [rustaceanvim](https://github.com/mrcjkb/rustaceanvim.git)
- [screenkey.nvim](https://github.com/NStefan002/screenkey.nvim.git)
- [tailwindcss-colorizer-cmp.nvim](https://github.com/roobert/tailwindcss-colorizer-cmp.nvim.git)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim.git)
- [tiny-devicons-auto-colors.nvim](https://github.com/rachartier/tiny-devicons-auto-colors.nvim.git)
- [todo-comments.nvim](https://github.com/folke/todo-comments.nvim.git)
- [tokyonight.nvim](https://github.com/folke/tokyonight.nvim.git)
- [tree-sitter-norg](https://github.com/nvim-neorg/tree-sitter-norg.git)
- [tree-sitter-norg-meta](https://github.com/nvim-neorg/tree-sitter-norg-meta.git)
- [treesj](https://github.com/Wansmer/treesj.git)
- [trouble.nvim](https://github.com/folke/trouble.nvim.git)
- [ts-comments.nvim](https://github.com/folke/ts-comments.nvim.git)
- [twilight.nvim](https://github.com/folke/twilight.nvim.git)
- [unicode.vim](https://github.com/chrisbra/unicode.vim.git)
- [venv-selector.nvim](https://github.com/linux-cultist/venv-selector.nvim.git)
- [vim-dadbod](https://github.com/tpope/vim-dadbod.git)
- [vim-dadbod-completion](https://github.com/kristijanhusak/vim-dadbod-completion.git)
- [vim-dadbod-ui](https://github.com/kristijanhusak/vim-dadbod-ui.git)
- [vim-helm](https://github.com/towolf/vim-helm.git)
- [vim-visual-multi](https://github.com/mg979/vim-visual-multi.git)
- [which-key.nvim](https://github.com/folke/which-key.nvim.git)
- [window-picker](https://github.com/s1n7ax/nvim-window-picker.git)
- [yanky.nvim](https://github.com/gbprod/yanky.nvim.git)
- [zen-mode.nvim](https://github.com/folke/zen-mode.nvim.git)