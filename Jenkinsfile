pipeline {
    agent { label 'jenkinsv2-jenkins-agent' }

    environment {
        IMAGE_NAME = "d4rkghost47/python-app"
    }

    stages {
        stage('Construir Imagen Docker') {
            steps {
                container('dind') {
                    script {
                        // Configurar el directorio como seguro para Git
                        sh "git config --global --add safe.directory /home/jenkins/agent/workspace/python-app"

                        // Obtener el short SHA del commit actual
                        def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "🐍 Construyendo imagen con SHA: ${shortSha}"

                        // Asegurar que el directorio de almacenamiento existe
                        sh "mkdir -p \$(pwd)"

                        // Guardar la imagen en el workspace
                        sh """
                        docker build -t ${IMAGE_NAME}:${shortSha} .
                        docker build -t ${IMAGE_NAME}:latest .

                        echo "📦 Guardando imagen en ${IMAGE_NAME}.tar..."
                        docker save -o \$(pwd)/python-app.tar ${IMAGE_NAME}:${shortSha} ${IMAGE_NAME}:latest

                        ls -lah \$(pwd)  # Verificar que el archivo se haya creado
                        """

                        // Guardar la imagen como artefacto en Jenkins
                        archiveArtifacts artifacts: "python-app.tar", fingerprint: true
                    }
                }
            }
        }

        stage('Subir Imagen Docker') {
            steps {
                container('dind') {
                    script {
                        // Asegurar que el archivo existe antes de cargarlo
                        sh "ls -lah \$(pwd)"

                        // Descargar la imagen guardada en el stage anterior
                        sh "docker load -i python-app.tar"

                        // Loguearse al registro usando credenciales seguras
                        withCredentials([string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')]) {
                            sh "echo '$DOCKER_TOKEN' | docker login -u 'd4rkghost47' --password-stdin"
                        }

                        // Subir la imagen al registro
                        sh """
                        echo "📤 Subiendo imagen Docker..."
                        docker push ${IMAGE_NAME}:latest
                        docker push ${IMAGE_NAME}:${shortSha}
                        """

                        echo "✅ Imagen subida con éxito"
                    }
                }
            }
        }
    }
}

