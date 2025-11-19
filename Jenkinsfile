pipeline {
    agent any

    environment {
        IMAGE = "gokulk306/trendstore-app"
        AWS_REGION = "us-east-2"
        CLUSTER_NAME = "trendstore-eks"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Gokulk-306/Trendstore-Project-2.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t $IMAGE:latest .
                """
            }
        }

        stage('Login to DockerHub & Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'USER',
                        passwordVariable: 'PASS'
                    )
                ]) {
                    sh """
                        echo $PASS | docker login -u $USER --password-stdin
                        docker push $IMAGE:latest
                    """
                }
            }
        }

        stage('Update kubeconfig for EKS') {
            steps {
                sh """
                    aws eks update-kubeconfig --region $AWS_REGION --name $CLUSTER_NAME
                """
            }
        }

        stage('Deploy to EKS via kubectl') {
            steps {
                sh """
                    kubectl apply -f deployment.yaml
                    kubectl apply -f service.yaml

                    echo "Waiting for pods to start..."
                    kubectl rollout status deployment/trendstore-deployment

                    echo "Deployment Completed Successfully!"
                """
            }
        }
    }
}
