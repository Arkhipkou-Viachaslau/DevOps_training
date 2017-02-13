node('master') {

	stage('git clone') {
		git branch: 'task4', credentialsId: 'git', url: 'https://github.com/Arkhipkou-Viachaslau/devops_training.git'
		sh 'chmod +x gradlew && ./gradlew updVersion && ./gradlew build'
	}

	stage('gitpush') {
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'git', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
			sh '''git add gradle.properties
			git commit -a -m "task4"
			git push https://${USERNAME}:${PASSWORD}@github.com/Arkhipkou-Viachaslau/devops_training.git task4'''
		}
	}

	sh '''cd /var/lib/jenkins/workspace/task4
	cat build/resources/main/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > currentVersion
	cp currentVersion /vagrant/currentVersion'''
	def currentVersion = readFile('currentVersion')

	stage('nexuspush') {
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'nexus', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
			sh "curl -XPUT -u ${USERNAME}:${PASSWORD} -T build/libs/task4.war http://172.20.20.10:8081/nexus/content/repositories/releases/training/task4/${currentVersion}/"
		}
	}

	node('noname1') {
		stage('nexus_to_noname1') {
			sh '''cd /home/vagrant/
			cp Dockerfile /home/vagrant/workspace/task4/
			cp Dockerfile /vagrant/Dockerfile
			cd /home/vagrant/workspace/task4/'''
			sh "sudo docker build --build-arg contversion=${currentVersion} -t localhost:5000/task4:${currentVersion} ."
			sleep 13
			sh "sudo docker push localhost:5000/task4:${currentVersion}"
			sleep 13
		}
	}

	node('noname2') {
		stage('registry_to_remote') {
			sh "sudo docker pull 172.20.20.30:5000/task4:${currentVersion}"
			sleep 13
			sh "sudo docker run -d -p 8080:8080 --name=task4remote 172.20.20.30:5000/task4:${currentVersion}"
			sleep 5
		}
		stage('versioncheck') {
			sh '''cd /home/vagrant/workspace/task4/
			curl http://172.20.20.31:8080/task4/ | grep -o "[0-9.]" | tr -d "\t\n" > containerVersion
			cp containerVersion /vagrant/containerVersion'''
			def containerVersion = readFile('containerVersion')
			if (containerVersion==currentVersion) {
				println "Container Version Up To Date"
				sh "sudo docker stop task4remote && sudo docker rm task4remote"
			} else {
				println "Update failed, retrying"
				sh "sudo docker stop task4remote && sudo docker rm task4remote"
				sh "sudo docker pull 172.20.20.30:5000/task4:${currentVersion}"
				sleep 13
				sh "sudo docker run -d -p 8080:8080 --name=task4remote 172.20.20.30:5000/task4:${currentVersion}"
				sleep 5
				println $currentVersion
				println $containerVersion
				sh "sudo docker stop task4remote && sudo docker rm task4remote"
			}
		}
	}
}