pipeline {
    agent { label 'registry' }
    environment {
        REGISTRY_PATH = '172.17.0.1'
        TAG='AWS-oligiovi'
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
                stage('Build Docker Images') {
                    steps {
                        sh 'echo "Start Docker build"'
                        sh 'docker build --rm -t $REGISTRY_PATH/connessioni ./connessioni'
                        sh 'docker build --rm -t $REGISTRY_PATH/recensioni ./recensioni'
                        sh 'docker build --rm -t $REGISTRY_PATH/recensioni-seguite ./recensioni-seguite'
                        sh 'docker build --rm -t $REGISTRY_PATH/apigateway ./api-gateway'
                        sh 'echo "Finish Docker build"'
                    }
                }
                stage('Push Docker Images') {
                    steps {
                        sh 'docker push $REGISTRY_PATH/connessioni'
                        sh 'docker push $REGISTRY_PATH/recensioni'
                        sh 'docker push $REGISTRY_PATH/recensioni-seguite'
                        sh 'docker push $REGISTRY_PATH/apigateway'
                    }
                }
            }
        }
        
        stage('Docker Operations') {
            agent {
                docker {
                    image 'docker:dind'
                    args '--privileged'
                }
            }
            stages {
                stage('Docker Test') {
                    steps {
                        sh 'docker --version'
                        sh 'docker-compose --version'
                        sh 'docker images'
                    }
                }
                stage('Pull Images') {
                    steps {
                        sh 'docker pull $REGISTRY_PATH/connessioni'
                        sh 'docker pull $REGISTRY_PATH/recensioni'
                        sh 'docker pull $REGISTRY_PATH/recensioni-seguite'
                        sh 'docker pull $REGISTRY_PATH/apigateway'
                    }
                }
                stage('Docker Compose Up') {
                    steps {
                        sh 'docker-compose up -d'
                    }
                }
                stage('Wait for Consul Services') {
                    environment {
                        CONSUL_URL = "http://localhost:8500/v1/health/state/any"
                    }
                    steps {
                        script {
                            def maxRetries = 30
                            def retryInterval = 10
                            def attempt = 0

                            while (attempt < maxRetries) {
                                def response = sh(script: "curl -s ${CONSUL_URL}", returnStdout: true).trim()
                                if (!response.contains('"Status":"critical"')) {
                                    echo "✅ All services are healthy!"
                                    break
                                } else {
                                    echo "⚠️ Some services are still critical. Retrying in ${retryInterval} seconds..."
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
                        sh 'docker-compose down'
                    }
                }
            }
        }
    }
}
