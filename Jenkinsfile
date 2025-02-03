// pipeline
pipeline {
    agent {
        label 'jenkinsv2-jenkins-agent'
    }

    triggers {
        githubPush() // Activa el pipeline en cada push
    }

    stages {
        stage('Construir y Subir Imagen Docker') {
            when { branch 'main' } // 🔥 Solo ejecuta este stage en "main"
            steps {
                container('dind') {
                    script {
                        // Configurar el directorio como seguro dentro del contenedor
                        sh '''
                        git config --global --add safe.directory /home/jenkins/agent/workspace/temp
                        '''

                        // Obtener el short SHA del commit actual
                        def shortSha = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                        echo "Commit Short SHA: ${shortSha}"

                        // Definir el nombre de la imagen para la app Python
                        def imageName = "d4rkghost47/python-app"

                        // Construcción de la imagen Docker con las etiquetas
                        sh """
                        echo "🐍 Construyendo imagen Docker para Python con tag: ${shortSha}..."
                        docker build -t ${imageName}:${shortSha} .
                        docker build -t ${imageName}:latest .
                        """

                        // Loguearse al registro
                        withCredentials([string(credentialsId: 'docker-token', variable: 'DOCKER_TOKEN')]) {
                            sh """
                            echo "$DOCKER_TOKEN" | docker login -u "d4rkghost47" --password-stdin
                            """
                        }

                        // Subir la imagen al registro
                        sh """
                        echo "📤 Subiendo imagen Docker al registro..."
                        docker push ${imageName}:${shortSha}
                        docker push ${imageName}:latest
                        """

                        echo "✅ Imagen Docker subida con éxito"
                    }
                }
            }
        }
    }
}

