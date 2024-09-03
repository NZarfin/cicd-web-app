pipeline {
    agent any

    environment {
        APP = 'target-app'
        SCOPE = 'user99'
        DB_NAME = 'mascots_db'
        DB_USER = 'nadavsecureDB'
        DB_PASSWORD = 'nadavsecureDBprivate'
    }

    stages {
        stage('Build Docker Image') {
            steps {
                // Build the Docker image
                sh '''
                docker build -t ${SCOPE}/${APP}:latest -f Dockerfile .
                '''
            }
        }

        stage('Start MySQL Service') {
            steps {
                // Start MySQL container
                sh '''
                docker run --name mysql-db -e MYSQL_ROOT_PASSWORD=root -e MYSQL_DATABASE=${DB_NAME} -e MYSQL_USER=${DB_USER} -e MYSQL_PASSWORD=${DB_PASSWORD} -d mysql:latest
                '''
                
                // Wait for MySQL to be ready
                sh '''
                sleep 30
                '''
            }
        }

        stage('Initialize Database') {
            steps {
                // Create the mascots table and populate it with initial data
                sh '''
                docker exec -i mysql-db mysql -u${DB_USER} -p${DB_PASSWORD} ${DB_NAME} <<EOF
                CREATE TABLE IF NOT EXISTS mascots (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    guid VARCHAR(36) NOT NULL,
                    mascot VARCHAR(100) NOT NULL,
                    school VARCHAR(100) NOT NULL,
                    nickname VARCHAR(100) NOT NULL,
                    location VARCHAR(100) NOT NULL,
                    latlong VARCHAR(100) NOT NULL
                );
                INSERT INTO mascots (guid, mascot, school, nickname, location, latlong) VALUES
                ('05024756-765e-41a9-89d7-1407436d9a58', 'Cy', 'Iowa State University', 'Cyclones', 'Ames, IA, USA', '42.026111,-93.648333');
                EOF
                '''
            }
        }

        stage('Run Application') {
            steps {
                // Run the application container with MySQL
                sh '''
                docker run --rm --name ${APP} --link mysql-db:mysql -p 8081:8081 -d ${SCOPE}/${APP}:latest
                '''
            }
        }

        stage('Run Linting') {
            steps {
                // Run flake8 for linting
                sh '''
                docker run --rm ${SCOPE}/${APP}:latest /opt/venv/bin/flake8 --ignore=E501,E231 /app/test_app.py /app/test_cyclones.py
                '''

                // Run pylint for additional linting
                sh '''
                docker run --rm ${SCOPE}/${APP}:latest /opt/venv/bin/pylint --errors-only --disable=C0301 /app/test_app.py /app/test_cyclones.py
                '''
            }
        }

        stage('Run Unit Tests') {
            steps {
                // Execute unit tests
                sh '''
                docker run --rm --link mysql-db:mysql ${SCOPE}/${APP}:latest /opt/venv/bin/python3 -m unittest --verbose --failfast /app/test_app.py /app/test_cyclones.py
                '''
            }
        }

        stage('Clean Up') {
            steps {
                // Clean up containers and Python cache files
                sh '''
                docker stop mysql-db || true
                docker rm mysql-db || true
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
            // Stop and remove the application container if the pipeline fails
            sh '''
            docker stop ${APP} || true
            docker rm ${APP} || true
            '''
        }
    }
}
