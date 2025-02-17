pipeline {
    agent { node 'Vagrant-AWS' }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'echo ciao mondo'
            }
        }
        stage('Build'){
            steps{
                sh '''
                    /usr/local/gradle/bin/gradle -v
                '''
            }
        }
    }
}
