pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
        REGISTRY = "https://index.docker.io/v1/"
        SHORT_SHA = '' // Variable para almacenar el SHA del commit
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {  // Asegurar que Docker está disponible
                    script {
                        sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"
                        // Obtener el SHA corto del commit y asignarlo a la variable global SHORT_SHA
                        env.SHORT_SHA = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🐍 Construyendo imagen con SHA: ${env.SHORT_SHA}"

                        sh """
                        docker build -t ${IMAGE_NAME}:${env.SHORT_SHA} .
                        docker tag ${IMAGE_NAME}:${env.SHORT_SHA} ${IMAGE_NAME}:latest
                        """
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('dind') {  // Asegurar que Docker está disponible
                    script {
                        withCredentials([string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')]) {
                            sh """
                            echo "$DOCKER_TOKEN" | docker login -u "d4rkghost47" --password-stdin
                            docker push ${IMAGE_NAME}:${env.SHORT_SHA}
                            docker push ${IMAGE_NAME}:latest
                            """
                        }
                    }
                }
            }
        }

        stage('Clean Up Local Images') {
            steps {
                container('dind') {  // Asegurar que Docker está disponible
                    script {
                        sh "docker rmi ${IMAGE_NAME}:${env.SHORT_SHA} || true"
                        sh "docker rmi ${IMAGE_NAME}:latest || true"
                    }
                }
            }
        }
    }
}

