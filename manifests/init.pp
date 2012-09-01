class java7 {
	$version = "1.7.0_06"
	$tarball = "jdk-7u6-linux-i586.tar.gz"
	
	package { "java-common":
		ensure => latest,
	}
	
	file { "java-tarball":
		ensure => file,
		path => "/tmp/$tarball",
		source => "puppet:///modules/java7/${tarball}", 
	}
	
	exec { "extract-java-tarball":
		command => "/bin/tar -xvzf ${tarball}",
		cwd => "/tmp",
		user => "root",
		creates => "/tmp/jdk${version}",
		require => File["java-tarball"],
	}
	
	file { "/usr/java":
		ensure => directory,
		owner => "root",
		group => "root",
		require => Exec["extract-java-tarball"],
	}

	exec { "move-java-directory":
		command => "/bin/cp -r jdk${version} /usr/java/jdk${version}",
		creates => "/usr/java/jdk${version}",
		cwd => "/tmp",
		user => "root",
		require => File["/usr/java"],
		notify => [
			Exec["install-java-alternative"],
			Exec["install-javac-alternative"]
		]
	}
	
	file { "/usr/java/latest":
		ensure => link,
		target => "/usr/java/jdk${version}",
		require => Exec["move-java-directory"]
	}
	
	exec { "install-java-alternative":
		command => '/usr/sbin/update-alternatives --install "/usr/bin/java" "java" "/usr/java/latest/bin/java" 1',
		refreshonly => true,
		require => File["/usr/java/latest"],
	}

	exec { "install-javac-alternative":
		command => '/usr/sbin/update-alternatives --install "/usr/bin/javac" "javac" "/usr/java/latest/bin/javac" 1',
		refreshonly => true,
		require => File["/usr/java/latest"],
	}
}