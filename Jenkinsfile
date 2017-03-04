def currentVersion = 'currentVersion'
def containerVersion = 'containerVersion'

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

	sh '''cat build/resources/main/greeting.txt | grep -o "[0-9.]" | tr -d "\t\n" > currentVersion'''
	currentVersion = readFile('currentVersion')

	stage('nexuspush') {
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'nexus', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
			sh "curl -XPUT -u ${USERNAME}:${PASSWORD} -T build/libs/task4.war http://172.20.20.10:8081/nexus/content/repositories/releases/training/task4/${currentVersion}/"
		}
	}

	stage('nexus_to_registry') {
		sh "sudo docker build --build-arg contversion=${currentVersion} -t localhost:5000/task4:${currentVersion} ."
		sleep 13
		sh "sudo docker push localhost:5000/task4:${currentVersion}"
		sleep 13
	}
}
node('noname1') {
	stage('registry_to_remote') {
		sh "sudo docker pull 172.20.20.10:5000/task4:${currentVersion}"
		sleep 13
		sh "sudo docker run -d -p 8080:8080 --name=task4remote 172.20.20.10:5000/task4:${currentVersion}"
		sleep 5
	}
	stage('versioncheck') {
		sh '''curl http://172.20.20.30:8080/task4/ | grep -o "[0-9.]" | tr -d "\t\n" > containerVersion'''
		containerVersion = readFile('containerVersion')
		if (containerVersion==currentVersion) {
			println "Container Version Up To Date"
			sh "sudo docker stop task4remote && sudo docker rm task4remote"
		} else {
			println "Something went wrong"
			sh "sudo docker stop task4remote && sudo docker rm task4remote"
		}
	}
}
