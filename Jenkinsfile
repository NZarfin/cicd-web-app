pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
    }

    stages {
        stage('Setup Python Environment') {
            steps {
                script {
                    // Set up Python virtual environment
                    sh 'python3 -m venv venv'
                    sh 'source venv/bin/activate'
                    
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
                // Build Docker image with the generated TAG
                sh "docker build -t ${SCOPE}/${APP}:${TAG} ."
            }
        }

        stage('Run Docker Container') {
            steps {
                // Run the Docker container on port 5000
                sh "docker run --rm -d -p 5000:5000 --name ${APP} ${SCOPE}/${APP}:${TAG}"
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

