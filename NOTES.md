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

