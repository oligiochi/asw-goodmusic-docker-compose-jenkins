pipeline {
    agent any/*
    parameters {
        string(name: 'TAG', defaultValue: 'AWS-oligiovi', description: 'Tag da usare per le immagini Docker')
    }*/
    environment {
        REGISTRY_PATH = '192.168.1.100'
        PORT = '5000'
    }
    stages {
        stage('Vagrant and Docker Operations') {
            agent { label 'AWS-Vagrant' }
            environment {
                // Aggiorna il PATH per gradle
                PATH = "/usr/local/gradle/bin:$PATH"
                // Overwrite REGISTRY_PATH se necessario per questo nodo
                REGISTRY_PATH = '10.0.2.2'
            }
            stages {
                stage('Check Env') {
                    steps {
                        sh '''
                        echo "Running on $(hostname)"
                        whoami
                        echo "PATH: $PATH"
                        which gradle || echo "Gradle non trovato!"
                        '''
                    }
                }
                stage('Build Gradle Project') {
                    steps {
                        sh 'gradle -v'
                        echo "Start Gradle build"
                        sh 'gradle build'
                        echo "Finish Gradle build"
                    }
                }
                stage('Build and Push Docker Images') {
                    steps {
                        script {
                            // Mappa delle immagini con relativi contesti
                            def images = [
                                [name: 'connessioni',       context: './connessioni'],
                                [name: 'recensioni',         context: './recensioni'],
                                [name: 'recensioni-seguite', context: './recensioni-seguite'],
                                [name: 'apigateway',         context: './api-gateway']
                            ]
                            
                            // Build e Push delle immagini con il tag passato come parametro
                            /*images.each { img ->
                                echo "Building image ${img.name} from context ${img.context}"
                                sh "docker build --rm -t ${REGISTRY_PATH}/${img.name}:${TAG} ${img.context}"
                                echo "Pushing image ${img.name}"
                                sh "docker push ${REGISTRY_PATH}/${img.name}:${TAG}"
                            }*/
                            for (img in images) {
                                echo "Building image ${img.name} from context ${img.context}"
                                sh "docker build --rm -t $REGISTRY_PATH/${img.name} ${img.context}"
                            }
                            
                            // Push delle immagini
                            for (img in images) {
                                echo "Pushing image ${img.name}"
                                sh "docker push $REGISTRY_PATH/${img.name}"
                            }
                        }
                    }
                }
            }
        }

        stage('Docker Operations') {
            agent { label 'local' }
            environment {
                DOCKER_HOST = 'unix:///var/run/docker.sock'
            }
            stages {
                stage('Docker Test') {
                    steps {
                        sh 'docker --version'
                        sh 'docker compose version'
                    }
                }
                stage('Pull, Tag and Remove Images') {
                    steps {
                        script {
                            def images = ['connessioni', 'recensioni', 'recensioni-seguite', 'apigateway']
                            
                            images.each { img ->
                                echo "Processing image ${img}"
                                sh "docker pull ${REGISTRY_PATH}:${PORT}/${img}:${TAG}"
                                sh "docker tag ${REGISTRY_PATH}:${PORT}/${img}:${TAG} ${img}:${TAG}"
                                sh "docker rmi ${REGISTRY_PATH}:${PORT}/${img}:${TAG}"
                            }
                        }
                    }
                }
                stage('Docker Compose Up') {
                    steps {
                        sh 'docker compose up -d'
                        sh "hostname -I | awk '{print \$1}'"
                    }
                }
                stage('Wait for Consul Services') {
                    environment {
                        CONSUL_URL = "http://192.168.1.102:8500/v1/health/state/critical"
                    }
                    steps {
                        script {
                            // Attende che Consul restituisca una risposta vuota, con timeout di 300 secondi
                            waitUntil(initialRecurrencePeriod: 10000, timeout: 300) {
                                def response = sh(script: "curl -s ${CONSUL_URL}", returnStdout: true).trim()
                                echo "Response from Consul: ${response}"
                                return response == "[]"
                            }
                            echo "✅ All services are healthy!"
                        }
                    }
                }
                stage('Test API') {
                    steps {
                        sh '''
                        curl -s 192.168.1.102:8081/recensioni/recensioni | jq . || echo "jq non disponibile, risposta grezza: $(curl -s 192.168.1.102:8081/recensioni/recensioni)"
                        '''
                    }
                }
                stage('Docker Compose Down') {
                    steps {
                        echo "Stopping app"
                        sh 'docker compose down'
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Cleaning up workspace"
            cleanWs()
        }
    }
}
