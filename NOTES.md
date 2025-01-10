# NOTES ABOUT ISSUES DURING INSTALL & CONFIGURATION

- When trying to install neo-tree:
  - Failed to install hererocks
    - Required:
      sudo apt install libreadline-dev lua-5.1 -y
- When trying to install neovim lsp servers:
  - Failed...
  - Required:sudo

        sudo apt install nodejs npm
        which npm
        vim ~/.bashrc
        #add
        export PATH=$PATH:/usr/bin/npm
        

- Addtional Requirements for my setup:

        sudo npm install -g vls dockerfile-language-server-nodejs \
        pyright gopls typescript typescript-language-server
        sudo apt install clangd ruby-full openjdk-17-jdk \
        python3-venv python3-pip codespell curl build-essential gcc make gnupg
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo tee /etc/apt/trusted.gpg.d/yarn.asc
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
        sudo apt update
        sudo apt install yarn
        sudo gem install bundler
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
        # Download [go](https://go.dev/dl/)
        sudo tar -C /usr/local -xvzf go1.23.4.linux-amd64.tar.gz 
        echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
        source ~/.bashrc
        source ~/.cargo/env
        cargo install stylua
        # After MarkdownPreview is installed:
        cd ~/.local/share/nvim/lazy/markdown-preview.nvim
        yarn install
        
        
