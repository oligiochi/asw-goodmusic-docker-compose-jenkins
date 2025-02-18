pipeline {
    agent { node 'AWS-Vagrant' }

    environment {
        // Aggiungi il percorso di Gradle al PATH globale per tutta la pipeline
        PATH = "/usr/local/gradle/bin:$PATH"
    }

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
                sh 'which gradle || echo "Gradle non trovato!"'
            }
        }
        stage('Build') {
            steps {
                sh '''
                    gradle -v
                    gradle build
                '''
            }
        }
    }
}
