# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

export GOROOT=/opt/go
export GOPATH=$HOME/go

PATH=$PATH:$HOME/.local/bin:$HOME/bin:$GOROOT/bin:$HOME/.cargo/bin:

export PATH
