pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
    }

    stages {
        stage('Build Docker Image with Python') {
            steps {
                script {
                    // Build a Docker image using the relative path to Dockerfile
                    sh "docker build -t ${SCOPE}/${APP}:python-env -f Dockerfile ."
                }
            }
        }

        stage('Setup Python Environment') {
            steps {
                script {
                    // Set up Python virtual environment inside the Docker container
                    sh "docker run --rm -v \$PWD:/app -w /app ${SCOPE}/${APP}:python-env python3 -m venv venv"
                    sh "source venv/bin/activate"
                    
                    // Generate the TAG variable after setting up the environment
                    TAG = "${new Date().format('yyyy-MM-dd')}-${sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()}"
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                // Install required Python packages inside the virtual environment
                sh '''
                    source venv/bin/activate
                    pip install --quiet --upgrade --requirement requirements.txt
                '''
            }
        }

        stage('Lint') {
            steps {
                // Run flake8 and pylint inside the virtual environment
                sh '''
                    source venv/bin/activate
                    flake8 --ignore=E501,E231 *.py
                    pylint --errors-only --disable=C0301 *.py
                '''
            }
        }

        stage('Unit Tests') {
            steps {
                // Run unit tests inside the virtual environment
                sh '''
                    source venv/bin/activate
                    python -m unittest --verbose --failfast
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build Docker image with the generated TAG using the relative path to Dockerfile
                sh "docker build -t ${SCOPE}/${APP}:${TAG} -f Dockerfile ."
            }
        }

        stage('Run Docker Container') {
            steps {
                // Run the Docker container on port 8081
                sh "docker run --rm -d -p 8081:8081 --name ${APP} ${SCOPE}/${APP}:${TAG}"
            }
        }

        stage('Clean Up') {
            steps {
                // Clean up Python environment, but do not stop the running Docker container
                sh '''
                    rm -rf ./__pycache__ ./tests/__pycache__
                    rm -f .*~ *.pyc
                '''
            }
        }
    }

    post {
        always {
            echo 'Pipeline execution finished.'
        }
        failure {
            // If the pipeline fails, stop and remove the Docker container
            sh '''
                docker rm -f ${APP} || true
            '''
        }
    }
}

