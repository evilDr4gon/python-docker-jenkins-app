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

	stage('Run Integration Test') {
        steps {
            container('dind') {
                script {
                    sh """
                    echo "🚀 Ejecutando contenedor para pruebas de integración..."
                    docker run -d --rm --name test-container -p 8080:8080 ${IMAGE_NAME}:${env.SHORT_SHA}
                    sleep 5  # Esperar que el contenedor inicie

                    echo "🔍 Probando endpoint /ping..."
                    docker exec test-container python -c "import urllib.request; exit(0) if urllib.request.urlopen('http://localhost:8080/ping').getcode() == 200 else exit(1)"

                    echo "🛑 Deteniendo contenedor..."
                    docker stop test-container                   
                    """
                }
            }
        }

	
	}

	stage
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
    }
}

