pipeline {
    agent any
    environment {
        REGISTRY_PATH = '192.168.1.100'
        PORT = '5000'
        TAG = 'AWS-oligiovi'
    }

    stages {
        stage('Vagrant and Docker Operations') {
            agent { label 'AWS-Vagrant' }
            environment {
                PATH = "/usr/local/gradle/bin:$PATH"
                REGISTRY_PATH = '10.0.2.2'
            }
            stages {
                stage('Check Env') {
                    steps {
                        sh 'echo "Running on $(hostname)"'
                        sh 'whoami'
                        sh 'echo "PATH: $PATH"'
                        sh 'which gradle || echo "Gradle non trovato!"'
                    }
                }
                stage('Build_Gradle') {
                    steps {
                        sh 'gradle -v'
                        sh 'echo "Start Gradle build"'
                        sh 'gradle build'
                        sh 'echo "Finish Gradle build"'
                    }
                }
                stage('Build and Push Docker Images') {
                    steps {
                        script {
                            // Definiamo la mappa delle immagini con relativo contesto
                            def images = [
                                [name: 'connessioni',       context: './connessioni'],
                                [name: 'recensioni',         context: './recensioni'],
                                [name: 'recensioni-seguite', context: './recensioni-seguite'],
                                [name: 'apigateway',         context: './api-gateway']
                            ]
                            
                            // Build delle immagini
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
                DOCKER_USERNAME = "tuo_username"
                DOCKER_PASSWORD = "tua_password"
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
                            
                            for (img in images) {
                                echo "Processing image ${img}"
                                sh "docker pull $REGISTRY_PATH:$PORT/${img}"
                                sh "docker tag $REGISTRY_PATH:$PORT/${img} ${img}"
                                sh "docker rmi $REGISTRY_PATH:$PORT/${img}"
                            }
                        }
                    }
                }
                stage('Docker Compose Up') {
                    steps {
                        sh 'docker login $REGISTRY_PATH:$PORT -u $DOCKER_USERNAME -p $DOCKER_PASSWORD'
                        sh 'docker compose up -d'
                    }
                }
                stage('Wait for Consul Services') {
                    environment {
                        CONSUL_URL = "http://localhost:8500/v1/health/state/critical"
                    }
                    steps {
                        sh "curl -s http://localhost:8500/v1/health/state/critical"
                        script {
                            def maxRetries = 30
                            def retryInterval = 10
                            def attempt = 0
                            
                            while (attempt < maxRetries) {
                                def response = sh(script: "curl -s http://localhost:8500/v1/health/state/critical", returnStdout: true).trim()
                                echo "Response from Consul: ${response}"
                                if (response == "[]") {
                                    echo "✅ All services are healthy!"
                                    break
                                } else {
                                    echo "⚠️ Some services are still in critical state. Retrying in ${retryInterval} seconds..."
                                    attempt++
                                    sleep retryInterval
                                }
                            }

                            if (attempt == maxRetries) {
                                error("❌ Services did not reach passing state within the timeout period!")
                            }
                        }
                    }
                }
                stage('Test API') {
                    steps {
                        sh 'echo $(curl -s localhost:2200/recensioni/recensioni) | jq .'
                    }
                }
                stage('Docker Compose Down') {
                    steps {
                        sh 'echo "Stopping app"'
                        sh 'docker compose down'
                    }
                }
            }
        }
    }
}
