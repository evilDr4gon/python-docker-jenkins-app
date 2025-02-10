// Pipeline v1.0.0
pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
        REGISTRY = "https://index.docker.io/v1/"
        SHORT_SHA = '' 
        RECIPIENTS = "jose_reynoso@siman.com,reynosojose2005@gmail.com"
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                container('dind') {  
                    script {
		        sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"
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
                        """
                    }
                }
            }
            post {
                always {
                    sh """
                    echo "🛑 Asegurando que el contenedor de prueba se detenga..."
                    docker stop test-container || true
                    """
                }
                success {
		    emailext subject: "✅ Éxito: Pruebas de integración en ${env.JOB_NAME}",
			     body: """
			     <h3 style='color:green;'>✅ Las pruebas de integración pasaron correctamente</h3>
			     <p>Pipeline: <b>${env.JOB_NAME}</b></p>
			     <p>Revisa los detalles en: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
			     """,
			     to: env.RECIPIENTS,
			     mimeType: 'text/html'
                }
                failure {
		    emailext subject: "❌ Falla: Pruebas de integración en ${env.JOB_NAME}",
			     body: """
			     <h3 style='color:red;'>❌ Las pruebas de integración fallaron</h3>
			     <p>Pipeline: <b>${env.JOB_NAME}</b></p>
			     <p>Ver logs aquí: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>
			     """,
			     to: env.RECIPIENTS,
			     mimeType: 'text/html'
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                container('dind') {  
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

