# NOTES ABOUT ISSUES DURING INSTALL & CONFIGURATION

- When trying to install neo-tree:
    - Failed to install hererocks
    - Required: 
    
        sudo apt install libreadline-dev lua-5.1 -y
- When trying to install neovim lsp servers:
    - Failed...
    - Required:
        
        sudo apt install nodejs npm
        which npm
        vim ~/.bashrc
        #add
        export PATH=$PATH:/usr/bin/npm

- Addtional Requirements for my setup:

    sudo npm install -g vls dockerfile-language-server-nodejs pyright gopls typescript typescript-language-server
    sudo apt install clangd ruby-full openjdk-17-jdk python3-venv
    sudo gem install bundler
    # Download [go](https://go.dev/dl/)
    sudo tar -C /usr/local -xvzf go1.23.4.linux-amd64.tar.gz 
    echo "export PATH=$PATH:/usr/local/go/bin" >> ~/.bashrc
    source ~/.bashrc
    

