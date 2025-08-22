#!/usr/bin/env python3
"""
Cascade-Claude Backend Bot - Real Django Development using Windsurf's Claude Integration
Uses BYOK (Bring Your Own Key) through Cascade for superior code generation
"""

import os
import sys
import json
import time
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import subprocess
import argparse

# Add scripts directory to path for bot_logger import
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from bot_logger import create_bot_logger

class CascadeClaudeBot:
    def __init__(self, project_path: str):
        self.project_path = Path(project_path)
        self.backend_path = self.project_path / 'scriby-backend'
        self.logger = create_bot_logger('cascade-claude', str(self.project_path))
        
        # Project context for Claude's superior reasoning
        self.project_context = {
            "name": "Scriby",
            "description": "Enterprise-grade AI transcription and meeting analysis platform",
            "tech_stack": ["Django 4.2", "Django REST Framework", "Celery", "Redis", "PostgreSQL", "OpenAI Whisper"],
            "features": [
                "Real-time audio recording with flutter_sound",
                "AI transcription using OpenAI Whisper API",
                "Advanced content analysis with GPT-4",
                "Automated meeting minutes generation",
                "Smart action items extraction",
                "Multi-tenant user management",
                "Subscription billing integration",
                "AARRR metrics tracking"
            ],
            "architecture": "Microservices with async task processing and event-driven design",
            "deployment": "Docker containerization with Kubernetes orchestration",
            "quality_requirements": "Production-ready, scalable, secure, well-tested"
        }
        
        print("🧠 Cascade-Claude Bot initialized with BYOK integration")
        print("🔑 Using your Claude API key through Windsurf Cascade")
    
    def generate_django_models_prompt(self) -> str:
        """Generate comprehensive prompt for Django models"""
        return f"""
You are a senior Django architect with 10+ years of experience building scalable web applications. 
Create production-ready Django models for the Scriby transcription platform.

Project Context:
{json.dumps(self.project_context, indent=2)}

Generate Django models for:

1. **User Management**:
   - Custom User model extending AbstractUser with subscription info
   - UserProfile with API usage tracking and quotas
   - UserSubscription with billing integration

2. **Audio Processing**:
   - Recording model with metadata (duration, file_size, format)
   - File storage with cloud integration (S3/GCS)
   - ProcessingStatus tracking with progress updates

3. **Transcription System**:
   - Transcription results with confidence scores
   - Multiple format support (SRT, VTT, JSON, plain text)
   - Version control for manual edits
   - Speaker identification and timestamps

4. **AI Analysis**:
   - Analysis results (summary, topics, action items)
   - Sentiment analysis scores and emotions
   - Custom analysis types and templates
   - Confidence metrics for AI outputs

5. **Business Logic**:
   - SubscriptionPlan with features and limits
   - UsageMetrics for AARRR tracking
   - BillingTransaction for payment processing
   - AuditLog for compliance and security

Requirements:
- Follow Django best practices and conventions
- Include proper field types, constraints, and indexes
- Add model methods, properties, and validation
- Use proper related_name attributes
- Include created_at/updated_at timestamps
- Add comprehensive __str__ methods and Meta classes
- Include docstrings for complex models
- Optimize for performance with select_related hints

Create a complete, production-ready models.py file with all necessary imports.
"""
    
    def generate_django_serializers_prompt(self, models_code: str) -> str:
        """Generate comprehensive prompt for DRF serializers"""
        return f"""
You are a Django REST Framework expert specializing in API design and serialization.
Create production-ready serializers with proper validation and performance optimization.

Based on the Django models provided, create comprehensive DRF serializers:

MODELS CODE:
```python
{models_code[:3000]}...
```

Generate serializers that include:

1. **ModelSerializers** for all models with:
   - Proper field selection and exclusions
   - Custom validation methods and business rules
   - Nested serialization for complex relationships
   - Performance optimizations (select_related/prefetch_related)

2. **Custom Serializers** for:
   - User registration with email verification
   - Authentication with JWT tokens
   - File upload with validation and progress
   - Complex API responses with computed fields

3. **Advanced Features**:
   - Dynamic field selection based on user permissions
   - Conditional field inclusion for different API versions
   - Custom to_representation methods for data transformation
   - Validation for business rules and constraints
   - Error message customization with i18n support

4. **API Endpoints Support**:
   - List/Detail views with filtering and search
   - Create/Update with comprehensive validation
   - File upload with security checks and progress tracking
   - Bulk operations with transaction support

Requirements:
- Follow DRF best practices and conventions
- Include comprehensive field validation
- Handle file uploads securely with size/type limits
- Optimize for performance (avoid N+1 queries)
- Include proper error handling with meaningful messages
- Add docstrings for complex serializers
- Support API versioning and backward compatibility

Create a complete, production-ready serializers.py file.
"""
    
    def generate_django_views_prompt(self, models_code: str, serializers_code: str) -> str:
        """Generate comprehensive prompt for Django REST API views"""
        return f"""
You are a senior Django REST Framework architect with expertise in building scalable APIs.
Create production-ready ViewSets and API views with proper authentication and security.

Based on the models and serializers, create comprehensive Django REST API views:

CONTEXT:
- Models: User, Recording, Transcription, Analysis, SubscriptionPlan, etc.
- Serializers: Comprehensive validation and nested relationships
- Requirements: Enterprise-grade security and performance

Generate ViewSets and APIViews that include:

1. **ModelViewSets** for CRUD operations:
   - JWT authentication with refresh token support
   - Permission classes (IsAuthenticated, IsOwner, custom permissions)
   - Advanced filtering, searching, and ordering
   - Pagination for large datasets with cursor pagination
   - Rate limiting per user/subscription plan

2. **Custom API Views** for:
   - User authentication (login, logout, refresh, password reset)
   - File upload with chunked upload support
   - Transcription processing triggers with status polling
   - Analytics and reporting endpoints with caching
   - Webhook handling for external integrations

3. **Business Logic Views**:
   - Audio processing workflow with status tracking
   - Real-time transcription status polling
   - AI analysis triggers with progress updates
   - Subscription management and billing integration
   - Usage tracking and quota enforcement

4. **Advanced Features**:
   - Custom actions for complex business operations
   - Bulk operations with validation and rollback
   - WebSocket support for real-time updates
   - API versioning with backward compatibility
   - Comprehensive logging and monitoring
   - Security headers and CORS configuration

Requirements:
- Use ViewSets where appropriate, APIViews for custom logic
- Include proper HTTP status codes and error responses
- Comprehensive error handling with structured error messages
- Add OpenAPI documentation with examples
- Implement proper logging for monitoring and debugging
- Include input validation and sanitization
- Handle file uploads securely with virus scanning
- Support for async task triggering (Celery integration)
- Add performance monitoring and metrics collection

Create a complete, production-ready views.py file with all necessary imports.
"""
    
    def generate_celery_tasks_prompt(self) -> str:
        """Generate comprehensive prompt for Celery tasks"""
        return f"""
You are a Celery expert specializing in async task processing and distributed systems.
Create production-ready Celery tasks for the Scriby transcription platform.

Project Context:
{json.dumps(self.project_context, indent=2)}

Generate comprehensive Celery tasks for:

1. **Audio Processing Pipeline**:
   - File validation and format conversion (MP3, WAV, M4A, etc.)
   - Audio quality enhancement and noise reduction
   - Metadata extraction (duration, bitrate, channels)
   - File storage optimization and compression
   - Chunking for large files

2. **AI Transcription**:
   - OpenAI Whisper API integration with retry logic
   - Progress tracking and real-time status updates
   - Error handling for API failures and rate limits
   - Result post-processing and formatting
   - Speaker diarization and timestamp alignment

3. **Content Analysis**:
   - GPT-4 content analysis with structured prompts
   - Summary generation with different lengths
   - Topic extraction and categorization
   - Action items identification with priorities
   - Sentiment analysis and emotion detection
   - Key phrase extraction and entity recognition

4. **Business Operations**:
   - Usage analytics calculation and aggregation
   - Billing and subscription updates
   - Email notifications with templates
   - Report generation (PDF, Excel, CSV)
   - Data cleanup and archival policies
   - Backup and disaster recovery

5. **System Maintenance**:
   - Health checks and system monitoring
   - Cache warming and invalidation
   - Database maintenance and optimization
   - Log rotation and cleanup
   - Performance metrics collection

Requirements:
- Use @shared_task decorator for reusability
- Include comprehensive error handling with custom exceptions
- Add retry strategies with exponential backoff and jitter
- Implement progress tracking with detailed status updates
- Include proper logging for debugging and monitoring
- Handle external API rate limits and quotas
- Add task result persistence with expiration
- Include cleanup for failed tasks and orphaned data
- Support task chaining and complex workflows
- Add monitoring hooks for Prometheus/Grafana
- Include circuit breaker pattern for external services
- Add task prioritization and queue management

Create a complete, production-ready tasks.py file with all necessary imports.
"""
    
    def generate_comprehensive_tests_prompt(self) -> str:
        """Generate comprehensive prompt for Django tests"""
        return f"""
You are a Django testing expert focused on comprehensive test coverage and quality assurance.
Create a production-ready test suite for the Scriby Django backend.

Generate tests that cover:

1. **Model Tests** (test_models.py):
   - Field validation and constraints testing
   - Model methods and properties verification
   - Relationship integrity and cascade behavior
   - Custom validators and clean methods
   - Edge cases and boundary conditions
   - Performance testing for complex queries

2. **API Tests** (test_api.py):
   - Authentication and authorization scenarios
   - CRUD operations for all endpoints
   - Permission testing with different user roles
   - Input validation and sanitization
   - Error handling and proper status codes
   - File upload functionality with edge cases
   - Rate limiting and throttling
   - API versioning compatibility

3. **Task Tests** (test_tasks.py):
   - Celery task execution and results
   - Error handling and retry mechanisms
   - Progress tracking and status updates
   - External API mocking (OpenAI, payment gateways)
   - Task chaining and workflow testing
   - Performance and timeout handling

4. **Integration Tests** (test_integration.py):
   - End-to-end workflow testing
   - API + Task integration scenarios
   - Database transaction integrity
   - File processing pipelines
   - Real-time notification systems
   - Third-party service integration

5. **Performance Tests** (test_performance.py):
   - Database query optimization verification
   - API response time benchmarks
   - Concurrent request handling
   - Memory usage and leak detection
   - Load testing scenarios

6. **Security Tests** (test_security.py):
   - Authentication bypass attempts
   - Authorization escalation testing
   - Input injection and XSS prevention
   - File upload security (malware, size limits)
   - Rate limiting effectiveness
   - Data privacy and GDPR compliance

Requirements:
- Use Django TestCase, APITestCase, and TransactionTestCase
- Include factory_boy for realistic test data generation
- Mock external API calls with proper error scenarios
- Test both success and failure paths comprehensively
- Include setUp and tearDown methods for clean state
- Add comprehensive docstrings and comments
- Use proper assertions with meaningful error messages
- Include edge cases, boundary testing, and error conditions
- Test file uploads, processing, and cleanup
- Cover security scenarios and attack vectors
- Add performance benchmarks and regression testing
- Include database migration testing
- Test async task execution and monitoring

Create a complete test suite with multiple test files organized by functionality.
Focus on achieving >95% code coverage with meaningful tests.
"""
    
    def create_file_with_content(self, filename: str, content: str, description: str):
        """Create a file with the given content and log the action"""
        file_path = self.backend_path / filename
        file_path.parent.mkdir(parents=True, exist_ok=True)
        
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        self.logger.log_file_created(str(file_path))
        self.logger.log_activity("FILE_CREATED", f"{description}: {filename}")
        print(f"  ✅ {description} created: {filename}")
        
        return str(file_path)
    
    def setup_django_project(self):
        """Setup Django project structure"""
        self.logger.log_activity("PROJECT_SETUP", "Setting up Django project structure")
        
        # Create directory
        self.backend_path.mkdir(parents=True, exist_ok=True)
        
        # Initialize Django project if not exists
        manage_py = self.backend_path / "manage.py"
        if not manage_py.exists():
            try:
                subprocess.run([
                    "django-admin", "startproject", "scriby_backend", "."
                ], cwd=self.backend_path, check=True)
                
                self.logger.log_command_executed("django-admin startproject scriby_backend .")
                self.logger.log_activity("PROJECT_SETUP", "Django project created successfully")
                print("  ✅ Django project structure initialized")
            except subprocess.CalledProcessError as e:
                self.logger.log_error(f"Failed to create Django project: {e}", "PROJECT_SETUP")
                raise
        else:
            print("  ✅ Django project already exists")
        
        # Create enhanced requirements.txt
        requirements = """# Core Django
Django==4.2.7
djangorestframework==3.14.0
django-cors-headers==4.3.1
django-extensions==3.2.3
django-filter==23.3

# Database
psycopg2-binary==2.9.9

# Async Processing
celery==5.3.4
redis==5.0.1

# AI/ML Integration
openai==1.3.5

# Authentication & Security
python-keycloak==3.7.0
djangorestframework-simplejwt==5.3.0
django-ratelimit==4.1.0

# File Handling & Storage
pillow==10.1.0
django-storages==1.14.2
boto3==1.34.0

# Configuration & Environment
python-decouple==3.8
django-environ==0.11.2

# Production & Performance
gunicorn==21.2.0
whitenoise==6.6.0
django-cachalot==2.6.1

# Development & Debugging
django-debug-toolbar==4.2.0
black==23.9.1
flake8==6.1.0
isort==5.12.0

# Testing & Quality
pytest-django==4.5.2
factory-boy==3.3.0
coverage==7.3.2
pytest-cov==4.1.0
pytest-mock==3.12.0

# Monitoring & Logging
sentry-sdk==1.38.0
django-prometheus==2.3.1

# API Documentation
drf-spectacular==0.26.5

# Task Monitoring
flower==2.0.1

# Email
django-anymail==10.2
"""
        
        requirements_file = self.backend_path / "requirements.txt"
        with open(requirements_file, 'w') as f:
            f.write(requirements.strip())
        
        self.logger.log_file_created(str(requirements_file))
        print("  ✅ Enhanced requirements.txt created")
    
    def run_cascade_development_cycle(self):
        """Run a complete development cycle using Cascade-Claude integration"""
        self.logger.log_cycle_start(1)
        
        try:
            print("🧠 Cascade-Claude is analyzing the project requirements...")
            
            # 1. Setup project structure
            self.setup_django_project()
            
            # 2. Generate models using Cascade-Claude
            print("  🧠 Cascade-Claude is designing the database models...")
            print("     Please use the following prompt in Cascade to generate Django models:")
            print("     " + "="*80)
            models_prompt = self.generate_django_models_prompt()
            
            # Save prompt to file for easy copying
            prompt_file = self.backend_path / "claude_prompts" / "models_prompt.txt"
            prompt_file.parent.mkdir(exist_ok=True)
            with open(prompt_file, 'w') as f:
                f.write(models_prompt)
            
            print(f"     📝 Models prompt saved to: {prompt_file}")
            print("     Copy this prompt to Cascade and save the response as models.py")
            print("     " + "="*80)
            
            # 3. Generate serializers prompt
            print("  🧠 Preparing serializers prompt...")
            serializers_prompt = self.generate_django_serializers_prompt("# Models will be generated by Cascade")
            serializers_prompt_file = self.backend_path / "claude_prompts" / "serializers_prompt.txt"
            with open(serializers_prompt_file, 'w') as f:
                f.write(serializers_prompt)
            print(f"     📝 Serializers prompt saved to: {serializers_prompt_file}")
            
            # 4. Generate views prompt
            print("  🧠 Preparing API views prompt...")
            views_prompt = self.generate_django_views_prompt("# Models and serializers will be generated", "# by Cascade")
            views_prompt_file = self.backend_path / "claude_prompts" / "views_prompt.txt"
            with open(views_prompt_file, 'w') as f:
                f.write(views_prompt)
            print(f"     📝 Views prompt saved to: {views_prompt_file}")
            
            # 5. Generate Celery tasks prompt
            print("  🧠 Preparing Celery tasks prompt...")
            tasks_prompt = self.generate_celery_tasks_prompt()
            tasks_prompt_file = self.backend_path / "claude_prompts" / "tasks_prompt.txt"
            with open(tasks_prompt_file, 'w') as f:
                f.write(tasks_prompt)
            print(f"     📝 Tasks prompt saved to: {tasks_prompt_file}")
            
            # 6. Generate tests prompt
            print("  🧠 Preparing comprehensive tests prompt...")
            tests_prompt = self.generate_comprehensive_tests_prompt()
            tests_prompt_file = self.backend_path / "claude_prompts" / "tests_prompt.txt"
            with open(tests_prompt_file, 'w') as f:
                f.write(tests_prompt)
            print(f"     📝 Tests prompt saved to: {tests_prompt_file}")
            
            # Create workflow instructions
            workflow_instructions = """# Cascade-Claude Development Workflow

## Step-by-Step Instructions:

1. **Generate Models** (models.py):
   - Copy the content from: claude_prompts/models_prompt.txt
   - Paste into Cascade chat
   - Save Claude's response as: scriby-backend/models.py

2. **Generate Serializers** (serializers.py):
   - Copy the content from: claude_prompts/serializers_prompt.txt
   - Update the prompt with the actual models.py content
   - Paste into Cascade chat
   - Save Claude's response as: scriby-backend/serializers.py

3. **Generate Views** (views.py):
   - Copy the content from: claude_prompts/views_prompt.txt
   - Update with actual models.py and serializers.py content
   - Paste into Cascade chat
   - Save Claude's response as: scriby-backend/views.py

4. **Generate Tasks** (tasks.py):
   - Copy the content from: claude_prompts/tasks_prompt.txt
   - Paste into Cascade chat
   - Save Claude's response as: scriby-backend/tasks.py

5. **Generate Tests** (tests.py):
   - Copy the content from: claude_prompts/tests_prompt.txt
   - Paste into Cascade chat
   - Save Claude's response as: scriby-backend/tests.py

## Benefits of Cascade-Claude Integration:
- ✅ Uses your BYOK (Bring Your Own Key) setup
- ✅ Superior code quality with Claude's advanced reasoning
- ✅ Full context awareness and conversation history
- ✅ Interactive refinement and iteration
- ✅ Cost control and transparency
- ✅ Integration with Windsurf IDE features

## After Generation:
1. Run: pip install -r requirements.txt
2. Run: python manage.py migrate
3. Run: python manage.py runserver
4. Test the API endpoints
5. Run the test suite: python manage.py test

Your Django backend will be production-ready with Claude's superior architecture!
"""
            
            workflow_file = self.backend_path / "CASCADE_CLAUDE_WORKFLOW.md"
            with open(workflow_file, 'w') as f:
                f.write(workflow_instructions)
            
            print(f"\n📋 Complete workflow instructions saved to: {workflow_file}")
            
            completed_tasks = [
                "Django project structure with enhanced dependencies",
                "Comprehensive prompts for Claude code generation",
                "Workflow instructions for Cascade integration",
                "Requirements.txt with production-ready packages",
                "Organized prompt files for systematic development",
                "BYOK integration setup for cost control"
            ]
            
            self.logger.log_cycle_complete(1, completed_tasks)
            
            return {
                "status": "prompts_ready",
                "ai_engine": "Cascade-Claude with BYOK",
                "prompts_generated": 5,
                "tasks_completed": completed_tasks,
                "integration_method": "Windsurf Cascade with your Claude API key"
            }
            
        except Exception as e:
            self.logger.log_error(f"Cascade-Claude development cycle failed: {str(e)}", "CYCLE_ERROR")
            raise

def main():
    parser = argparse.ArgumentParser(description='Cascade-Claude Backend Bot - BYOK Integration')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    args = parser.parse_args()
    
    try:
        bot = CascadeClaudeBot("/Users/ciroarendt/CURSOR/APP_11me/transcription_app")
        
        print("🤖 Cascade-Claude Backend Bot - BYOK Integration")
        print("🔑 Using your Claude API key through Windsurf Cascade")
        print("🧠 Superior code generation with Claude's advanced reasoning")
        print("=" * 70)
        
        if args.continuous:
            print("🔄 Running in CONTINUOUS mode with Cascade-Claude...")
            cycle = 0
            while True:
                try:
                    cycle += 1
                    print(f"\n🧠 Cascade-Claude Development Cycle #{cycle}")
                    
                    result = bot.run_cascade_development_cycle()
                    
                    print(f"\n✅ Cycle #{cycle} completed with Cascade-Claude:")
                    print(f"   🧠 AI Engine: {result['ai_engine']}")
                    print(f"   📝 Prompts generated: {result['prompts_generated']}")
                    print(f"   ✅ Tasks: {len(result['tasks_completed'])}")
                    print(f"   🔑 Integration: {result['integration_method']}")
                    
                    time.sleep(120)  # Wait 2 minutes between cycles
                    
                except KeyboardInterrupt:
                    print("\n🛑 Cascade-Claude development stopped")
                    break
                except Exception as e:
                    print(f"❌ Error in Cascade-Claude cycle #{cycle}: {e}")
                    time.sleep(60)  # Wait before retry
        else:
            # Single run mode
            print("🧠 Running single Cascade-Claude development cycle...")
            result = bot.run_cascade_development_cycle()
            
            print("\n🎉 Cascade-Claude Backend Bot completed successfully!")
            print(f"🧠 AI Engine: {result['ai_engine']}")
            print(f"📝 Generated {result['prompts_generated']} comprehensive prompts")
            print(f"🔑 Integration: {result['integration_method']}")
            print("\n📋 Next steps:")
            print("  1. Open CASCADE_CLAUDE_WORKFLOW.md for detailed instructions")
            print("  2. Use the prompts in claude_prompts/ folder with Cascade")
            print("  3. Generate production-ready Django code with Claude")
            print("  4. Test and deploy your superior backend!")
            print("\n🚀 Your Cascade-Claude integration is ready!")
            
    except Exception as e:
        print(f"❌ Cascade-Claude Backend Bot failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
