pipeline {
    agent any

    environment {
        REPO_URL = 'https://github.com/AyeKyiPyar/p-t-cucumber.git'
        APP_IMAGE = 'player-team-cucumber:v1.1'
        APP_CONTAINER = 'player-team-cucumber-container'
        APP_PORT = '8083'
        MYSQL_CONTAINER = 'mysql_db'
        MYSQL_NETWORK = 'akpsnetwork'
    }

    stages {

        stage('Checkout') {
            steps {
                echo '📦 Cloning repository...'
                git branch: 'main', url: "${REPO_URL}"
            }
        }

        stage('Build') {
            steps {
                echo '🏗️ Building Maven project...'
                bat 'mvn clean package -DskipTests'
            }
        }

        stage('Start MySQL for Tests') {
            steps {
                script {
                    def mysqlRunning = bat(script: "docker ps -q -f name=%MYSQL_CONTAINER%", returnStdout: true).trim()
                    if (mysqlRunning == '') {
                        echo '🟢 Starting MySQL container...'
                        // Ensure network exists
                        bat "docker network inspect %MYSQL_NETWORK% || docker network create %MYSQL_NETWORK%"
                        bat '''
                            docker run -d --name mysql_db ^
                            --network akpsnetwork ^
                            -e MYSQL_ROOT_PASSWORD=root ^
                            -e MYSQL_DATABASE=testdb ^
                            -p 3306:3306 ^
                            mysql:8.0
                        '''
                    } else {
                        echo '✅ MySQL container already running.'
                    }
                }
            }
        }

        stage('Run Cucumber Tests') {
            steps {
                echo '🧪 Running Cucumber tests...'
                bat 'mvn test -Dcucumber.options="--plugin json:target/cucumber.json"'
            }
        }

        

        stage('Build Docker Image') {
            steps {
                echo '🐳 Building Spring Boot Docker image...'
                bat "docker build -t %APP_IMAGE% ."
            }
        }

        stage('Deploy Spring Boot Container') {
            steps {
                script {
                    echo '🚀 Deploying Spring Boot app...'

                   echo '🚀 Run new container detached...'
                    bat """
                        docker run -d --name %APP_CONTAINER% --network %MYSQL_NETWORK% -p %APP_PORT%:8080 %APP_IMAGE%
                    """
                    bat 'powershell -Command "Start-Sleep -Seconds 20"'
                }
            }
        }
    }

    post {
        always {
            echo '✅ Pipeline finished. Current Docker containers:'
            bat 'docker ps -a'
        }
        success {
            echo "🎉 Pipeline succeeded! App running at http://localhost:%APP_PORT%/"
        }
        failure {
            echo '❌ Pipeline failed. Check logs above.'
        }
    }
}
