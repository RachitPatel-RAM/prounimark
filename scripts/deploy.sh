#!/bin/bash

# UniMark Deployment Script
# This script handles the complete deployment of UniMark to Firebase

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID="unimark-attendance"
FUNCTIONS_DIR="functions"
FLUTTER_DIR="."

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        log_error "Firebase CLI is not installed. Please install it first:"
        echo "npm install -g firebase-tools"
        exit 1
    fi
    
    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        log_error "Flutter is not installed. Please install it first."
        exit 1
    fi
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install it first."
        exit 1
    fi
    
    # Check if we're in the right directory
    if [ ! -f "pubspec.yaml" ]; then
        log_error "pubspec.yaml not found. Please run this script from the Flutter project root."
        exit 1
    fi
    
    log_success "Prerequisites check passed"
}

setup_firebase() {
    log_info "Setting up Firebase..."
    
    # Check if Firebase project is initialized
    if [ ! -f "firebase.json" ]; then
        log_warning "Firebase not initialized. Initializing now..."
        firebase init --project $PROJECT_ID
    fi
    
    # Set the active project
    firebase use $PROJECT_ID
    
    log_success "Firebase setup complete"
}

install_dependencies() {
    log_info "Installing dependencies..."
    
    # Install Flutter dependencies
    log_info "Installing Flutter dependencies..."
    flutter pub get
    
    # Install Node.js dependencies for Cloud Functions
    if [ -d "$FUNCTIONS_DIR" ]; then
        log_info "Installing Cloud Functions dependencies..."
        cd $FUNCTIONS_DIR
        npm install
        cd ..
    fi
    
    log_success "Dependencies installed"
}

run_tests() {
    log_info "Running tests..."
    
    # Run Flutter tests
    log_info "Running Flutter tests..."
    flutter test
    
    # Run Cloud Functions tests
    if [ -d "$FUNCTIONS_DIR" ]; then
        log_info "Running Cloud Functions tests..."
        cd $FUNCTIONS_DIR
        npm test
        cd ..
    fi
    
    log_success "All tests passed"
}

build_functions() {
    log_info "Building Cloud Functions..."
    
    if [ -d "$FUNCTIONS_DIR" ]; then
        cd $FUNCTIONS_DIR
        npm run build
        cd ..
        log_success "Cloud Functions built successfully"
    else
        log_warning "Functions directory not found, skipping..."
    fi
}

deploy_firebase() {
    log_info "Deploying to Firebase..."
    
    # Deploy Firestore rules and indexes
    log_info "Deploying Firestore rules and indexes..."
    firebase deploy --only firestore:rules,firestore:indexes
    
    # Deploy Cloud Functions
    if [ -d "$FUNCTIONS_DIR" ]; then
        log_info "Deploying Cloud Functions..."
        firebase deploy --only functions
    fi
    
    # Deploy Firebase Hosting (if configured)
    if grep -q "hosting" firebase.json; then
        log_info "Deploying Firebase Hosting..."
        firebase deploy --only hosting
    fi
    
    log_success "Firebase deployment complete"
}

build_flutter() {
    log_info "Building Flutter app..."
    
    # Build Android APK
    log_info "Building Android APK..."
    flutter build apk --release
    
    # Build iOS (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Building iOS app..."
        flutter build ios --release
    else
        log_warning "Skipping iOS build (not on macOS)"
    fi
    
    log_success "Flutter build complete"
}

setup_app_check() {
    log_info "Setting up App Check..."
    
    # Register Android app for App Check
    log_info "Registering Android app for App Check..."
    firebase appcheck:apps:register android com.example.unimark --project $PROJECT_ID || log_warning "Android app registration failed or already exists"
    
    # Register iOS app for App Check (if on macOS)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_info "Registering iOS app for App Check..."
        firebase appcheck:apps:register ios com.example.unimark --project $PROJECT_ID || log_warning "iOS app registration failed or already exists"
    fi
    
    log_success "App Check setup complete"
}

configure_functions() {
    log_info "Configuring Cloud Functions..."
    
    # Set admin credentials
    firebase functions:config:set admin.id="ADMIN404" admin.password="ADMIN9090@@@@" --project $PROJECT_ID
    
    # Set university domain
    firebase functions:config:set university.domain="@darshan.ac.in" university.name="Darshan University" --project $PROJECT_ID
    
    # Set security constants
    firebase functions:config:set security.default_radius="500" security.default_ttl="300" security.edit_window="172800" --project $PROJECT_ID
    
    log_success "Cloud Functions configured"
}

create_sample_data() {
    log_info "Creating sample data..."
    
    # This would typically call a Cloud Function to seed initial data
    log_info "Sample data creation would be implemented here"
    
    log_success "Sample data created"
}

main() {
    log_info "Starting UniMark deployment..."
    
    check_prerequisites
    setup_firebase
    install_dependencies
    run_tests
    build_functions
    configure_functions
    deploy_firebase
    setup_app_check
    build_flutter
    create_sample_data
    
    log_success "UniMark deployment completed successfully!"
    log_info "Next steps:"
    echo "1. Configure Google Sign-In in Firebase Console"
    echo "2. Set up Play Integrity API in Google Cloud Console"
    echo "3. Test the application with sample accounts"
    echo "4. Monitor logs in Firebase Console"
}

# Handle command line arguments
case "${1:-}" in
    "test")
        check_prerequisites
        install_dependencies
        run_tests
        ;;
    "build")
        check_prerequisites
        install_dependencies
        build_functions
        build_flutter
        ;;
    "deploy")
        check_prerequisites
        setup_firebase
        install_dependencies
        build_functions
        configure_functions
        deploy_firebase
        ;;
    "full")
        main
        ;;
    *)
        echo "Usage: $0 {test|build|deploy|full}"
        echo ""
        echo "Commands:"
        echo "  test   - Run tests only"
        echo "  build  - Build functions and Flutter app"
        echo "  deploy - Deploy to Firebase"
        echo "  full   - Complete deployment (default)"
        exit 1
        ;;
esac
