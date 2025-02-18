pipeline {
    agent { node 'AWS-Vagrant' }

    stages {
        stage('Hello') {
            steps {
                echo 'Hello World'
                sh 'echo ciao mondo'
            }
        }
        stage('Check Env') {
            steps {
                sh 'echo "Running on $(hostname)"'
                sh 'whoami'  // Mostra l'utente con cui gira il job
                sh 'echo "PATH: $PATH"'
                sh '''
                if ! which gradle > /dev/null; then
                        export PATH=$PATH:/usr/local/gradle/bin
                        echo "Gradle aggiunto al PATH"
                    fi
                '''
                sh 'which gradle'
            }
        }
        stage('Build'){
            steps{
                sh '''
                    gradle -v
                '''
            }
        }
    }
}
