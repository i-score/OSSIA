if [[ "$TRAVIS_OS_NAME" = "linux" ]]; then
	sudo add-apt-repository --yes ppa:ubuntu-toolchain-r/test
	sudo add-apt-repository --yes ppa:beineri/opt-qt532
	sudo apt-get update -qq
	sudo apt-get install -qq qt53-meta-full libportmidi-dev libgecode-dev libxml2-dev libsndfile-dev portaudio19-dev libportmidi-dev
	wget https://www.dropbox.com/s/e0o670ve6gv1dgt/cmake-3.0.2-Linux-x86_64.tar.gz?dl=1 -O cmake-3.0.2-Linux-x86_64.tar.gz
	tar zxf cmake-3.0.2-Linux-x86_64.tar.gz
	wget https://www.dropbox.com/s/exjazsh5epqet2g/gcc_4.9.1-1_amd64.deb?dl=1 -O gcc_4.9.1-1_amd64.deb
	sudo dpkg -i gcc_4.9.1-1_amd64.deb
	
	export CMAKE_PATH="$(pwd)/cmake-3.0.2-Linux-x86_64/bin"
	source /opt/qt53/bin/qt53-env.sh
	exec sh -c 'PATH=$CMAKE_PATH:$PATH ./Build.sh jamoma iscore --clone'
else 
	exec ./Build.sh jamoma iscore --clone --install-deps
fi
	
