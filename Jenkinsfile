pipeline {
    agent any

    environment {
        PROJECT_ID = "swift-castle-475200-j1"   // replace with your GCP project ID
        REGION = "us-central1"                  // replace with your region
        SERVICE_NAME = "cloud-run-jenkins-demo" // replace with your Cloud Run service name
        IMAGE_NAME = "cloud-run-jenkins-image"
        ARTIFACT_REPO = "node-repo"        // replace with your Artifact Registry repo name
        GOOGLE_APPLICATION_CREDENTIALS = credentials('gcp-service-account-key')
        GCLOUD_PATH = "\"C:\\Program Files (x86)\\Google\\Cloud SDK\\google-cloud-sdk\\bin\\gcloud.cmd\""
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                git branch: 'main', url: 'https://github.com/seunking05/Cloud-Run-POC.git', credentialsId: 'github-pat'
            }
        }

        stage('Setup gcloud CLI') {
            steps {
                echo "Authenticating GCP service account..."
                bat """
                    ${GCLOUD_PATH} auth activate-service-account --key-file=%GOOGLE_APPLICATION_CREDENTIALS%
                    ${GCLOUD_PATH} config set project %PROJECT_ID%
                    ${GCLOUD_PATH} config set run/region %REGION%
                """
            }
        }

        stage('Configure Docker Authentication') {
            steps {
                echo "Configuring Docker authentication for Artifact Registry..."
                bat """
                    ${GCLOUD_PATH} auth configure-docker %REGION%-docker.pkg.dev --quiet
                """
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "Building Docker image..."
                bat """
                    docker build -t %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:latest .
                """
            }
        }

        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image to Artifact Registry..."
                bat """
                    docker push %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:latest
                """
            }
        }

        stage('Deploy to Cloud Run') {
            steps {
                echo "Deploying to Cloud Run..."
                bat """
                    ${GCLOUD_PATH} run deploy %SERVICE_NAME% ^
                        --image %REGION%-docker.pkg.dev/%PROJECT_ID%/%ARTIFACT_REPO%/%IMAGE_NAME%:latest ^
                        --region %REGION% ^
                        --platform managed ^
                        --allow-unauthenticated
                """
            }
        }
    }

    post {
        success {
            echo "✅ Deployment completed successfully!"
        }
        failure {
            echo "❌ Deployment failed. Check the Jenkins logs for details."
        }
    }
}
