node('master') {

	stage('git clone') {
		git branch: 'task3', credentialsId: 'git', url: 'https://github.com/Arkhipkou-Viachaslau/devops_training.git'
		sh 'chmod +x gradlew && ./gradlew updVersion && ./gradlew build'
	}

	stage('gitpush') {
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'git', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
			sh '''git add gradle.properties
			git commit -a -m "test2"
			git push https://${USERNAME}:${PASSWORD}@github.com/Arkhipkou-Viachaslau/devops_training.git task3'''
		}
	}

	sh '''cd /var/lib/jenkins/workspace/task3
	cat build/resources/main/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > currentVersion
	cp currentVersion /vagrant/currentVersion'''
	def currentVersion = readFile('currentVersion')

	stage('nexuspush') {
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'nexus', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
			sh "curl -XPUT -u ${USERNAME}:${PASSWORD} -T build/libs/task3.war http://172.20.20.10:8081/nexus/content/repositories/releases/training/task3/${currentVersion}/"
		}
	}

	stage('tomcat1 stop') {
		httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=1'
	}

	stage('nexus to tomcat1') {
		node('tomcat1') {
			sh '''cd /usr/share/tomcat/webapps/
			sudo rm -rf task3 && sudo rm -rf task3.war'''
			sh "sudo wget -P /usr/share/tomcat/webapps/ http://172.20.20.10:8081/nexus/content/repositories/releases/training/task3/${currentVersion}/task3.war"
			sleep 20
			sh '''cd /usr/share/tomcat/webapps/task3/
			cat WEB-INF/classes/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > /home/vagrant/workspace/currentVersionTomcat1
			cd /home/vagrant/workspace/
			cp currentVersionTomcat1 /vagrant/currentVersionTomcat1'''
			def currentVersionTomcat1 = readFile('/home/vagrant/workspace/currentVersionTomcat1')

			stage('version check tomcat1') {
				if (currentVersionTomcat1==currentVersion) {
					println "Version up to date"
					httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=0'
				} else {
					println "Update failed..retrying"
					sh '''cd /usr/share/tomcat/webapps/
					sudo rm -rf task3 && sudo rm -rf task3.war'''
					sh "sudo wget -P /usr/share/tomcat/webapps/ http://172.20.20.10:8081/nexus/content/repositories/releases/training/task3/${currentVersion}/task3.war"
					sleep 20
					sh '''cd /usr/share/tomcat/webapps/task3/
					cat WEB-INF/classes/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > /home/vagrant/workspace/currentVersionTomcat1
					cd /home/vagrant/workspace/
					cp currentVersionTomcat1 /vagrant/currentVersionTomcat1'''
					println $currentVersionTomcat1
					println $currentVersion
					httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=0'
				}
			}
		}
	}

	stage('tomcat2 stop') {
		httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=1'
	}

	stage('nexus to tomcat2') {
		node('tomcat2') {
			sh '''cd /usr/share/tomcat/webapps/
			sudo rm -rf task3 && sudo rm -rf task3.war'''
			sh "sudo wget -P /usr/share/tomcat/webapps/ http://172.20.20.10:8081/nexus/content/repositories/releases/training/task3/${currentVersion}/task3.war"
			sleep 20
			sh '''cd /usr/share/tomcat/webapps/task3/
			cat WEB-INF/classes/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > /home/vagrant/workspace/currentVersionTomcat2
			cd /home/vagrant/workspace/
			cp currentVersionTomcat2 /vagrant/currentVersionTomcat2'''
			def currentVersionTomcat2 = readFile('/home/vagrant/workspace/currentVersionTomcat2')

			stage('version check tomcat2') {
				if (currentVersionTomcat2==currentVersion) {
					println "Version up to date"
					httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=0'
				} else {
					println "Update failed..retrying"
					sh '''cd /usr/share/tomcat/webapps/
					sudo rm -rf task3 && sudo rm -rf task3.war'''
					sh "sudo wget -P /usr/share/tomcat/webapps/ http://172.20.20.10:8081/nexus/content/repositories/releases/training/task3/${currentVersion}/task3.war"
					sleep 20
					sh '''cd /usr/share/tomcat/webapps/task3/
					cat WEB-INF/classes/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > /home/vagrant/workspace/currentVersionTomcat2
					cd /home/vagrant/workspace/
					cp currentVersionTomcat2 /vagrant/currentVersionTomcat2'''
					println $currentVersionTomcat2
					println $currentVersion
					httpRequest 'http://172.20.20.10/jk-status?cmd=update&from=list&w=lb&sw=tomcat1&vwa=0'
				}
			}
		}
	}    
}