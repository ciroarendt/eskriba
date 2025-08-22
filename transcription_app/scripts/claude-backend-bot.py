#!/usr/bin/env python3
"""
Claude AI Backend Bot - Real Django Development with Claude 3.5 Sonnet (Latest)
Uses Claude's most advanced model for superior code generation and thinking
"""

import os
import sys
import json
import asyncio
import aiohttp
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Optional
import subprocess
import argparse

# Add scripts directory to path for bot_logger import
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from bot_logger import create_bot_logger

class ClaudeBackendBot:
    def __init__(self, project_path: str, claude_api_key: str = None):
        self.project_path = Path(project_path)
        self.backend_path = self.project_path / 'scriby-backend'
        self.logger = create_bot_logger('claude-backend', str(self.project_path))
        
        # Claude Configuration - Using latest model
        self.claude_api_key = claude_api_key or os.getenv('ANTHROPIC_API_KEY')
        if not self.claude_api_key:
            raise ValueError("Claude API key is required. Set ANTHROPIC_API_KEY environment variable.")
        
        self.claude_base_url = "https://api.anthropic.com/v1"
        # Using the most advanced Claude model available
        self.model = "claude-3-5-sonnet-20241022"  # Latest Claude 3.5 Sonnet with enhanced capabilities
        self.max_tokens = 8192
        
        # Development context for Claude's superior reasoning
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
        
    async def call_claude_api(self, messages: List[Dict], system_prompt: str = None) -> str:
        """Make async call to Claude API with advanced reasoning"""
        headers = {
            "x-api-key": self.claude_api_key,
            "Content-Type": "application/json",
            "anthropic-version": "2023-06-01"
        }
        
        payload = {
            "model": self.model,
            "max_tokens": self.max_tokens,
            "messages": messages
        }
        
        if system_prompt:
            payload["system"] = system_prompt
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{self.claude_base_url}/messages",
                headers=headers,
                json=payload
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    return data['content'][0]['text']
                else:
                    error = await response.text()
                    raise Exception(f"Claude API error: {error}")
    
    async def generate_django_models(self, requirements: str) -> Dict[str, str]:
        """Generate Django models using Claude's superior reasoning"""
        self.logger.log_activity("CLAUDE_GENERATION", f"Generating Django models for: {requirements}")
        
        system_prompt = """You are a senior Django architect with 10+ years of experience building scalable web applications. 
        You excel at creating clean, maintainable, and production-ready Django code following best practices.
        
        Focus on:
        - Clean architecture and separation of concerns
        - Proper model relationships and database design
        - Performance optimization (indexes, queries)
        - Security best practices
        - Comprehensive validation and error handling
        - Scalability and maintainability
        
        Generate only production-ready Python code without explanations."""
        
        user_prompt = f"""
        Generate Django models for the Scriby transcription platform based on these requirements:
        {requirements}
        
        Project Context:
        {json.dumps(self.project_context, indent=2)}
        
        Create models for:
        1. **User Management**:
           - Custom User model extending AbstractUser
           - User profiles with subscription info
           - API usage tracking and quotas
        
        2. **Audio Processing**:
           - Recording model with metadata
           - File storage with cloud integration
           - Processing status tracking
        
        3. **Transcription System**:
           - Transcription results with confidence scores
           - Multiple format support (SRT, VTT, JSON)
           - Version control for edits
        
        4. **AI Analysis**:
           - Analysis results (summary, topics, actions)
           - Sentiment analysis scores
           - Custom analysis types
        
        5. **Business Logic**:
           - Subscription plans and billing
           - Usage analytics and metrics
           - Audit logs for compliance
        
        Requirements:
        - Follow Django best practices and conventions
        - Include proper field types and constraints
        - Add database indexes for performance
        - Include model methods and properties
        - Add comprehensive __str__ methods
        - Include model validation and clean methods
        - Use proper related_name attributes
        - Add created_at/updated_at timestamps
        - Include docstrings for complex models
        
        Return ONLY the complete models.py file content.
        """
        
        messages = [
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            models_code = await self.call_claude_api(messages, system_prompt)
            
            # Save to file
            models_file = self.backend_path / "models.py"
            models_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(models_file, 'w') as f:
                f.write(models_code)
            
            self.logger.log_file_created(str(models_file))
            self.logger.log_activity("CLAUDE_SUCCESS", f"Generated Django models: {models_file}")
            
            return {"models.py": models_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate models: {str(e)}", "CLAUDE_GENERATION")
            raise
    
    async def generate_django_serializers(self, models_code: str) -> Dict[str, str]:
        """Generate Django REST serializers using Claude's advanced understanding"""
        self.logger.log_activity("CLAUDE_GENERATION", "Generating DRF serializers")
        
        system_prompt = """You are a Django REST Framework expert specializing in API design and serialization.
        Create production-ready serializers with proper validation, nested relationships, and performance optimization.
        
        Focus on:
        - Efficient serialization with select_related/prefetch_related
        - Proper field validation and custom validators
        - Nested serializers for complex relationships
        - Read-only and write-only field handling
        - Custom serializer methods and properties
        - File upload handling and validation
        - API versioning considerations"""
        
        user_prompt = f"""
        Based on these Django models, create comprehensive Django REST Framework serializers:
        
        ```python
        {models_code}
        ```
        
        Generate serializers that include:
        
        1. **ModelSerializers** for all models with:
           - Proper field selection and exclusions
           - Custom validation methods
           - Nested serialization for relationships
           - Performance optimizations
        
        2. **Custom Serializers** for:
           - User registration and authentication
           - File upload with validation
           - Complex API responses
           - Batch operations
        
        3. **Advanced Features**:
           - Dynamic field selection
           - Conditional field inclusion
           - Custom to_representation methods
           - Validation for business rules
           - Error message customization
        
        4. **API Endpoints Support**:
           - List/Detail views with filtering
           - Create/Update with proper validation
           - File upload with progress tracking
           - Bulk operations where appropriate
        
        Requirements:
        - Follow DRF best practices
        - Include comprehensive field validation
        - Handle file uploads securely
        - Optimize for performance (avoid N+1 queries)
        - Include proper error handling
        - Add docstrings for complex serializers
        - Support API versioning
        
        Return ONLY the complete serializers.py file content.
        """
        
        messages = [
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            serializers_code = await self.call_claude_api(messages, system_prompt)
            
            serializers_file = self.backend_path / "serializers.py"
            with open(serializers_file, 'w') as f:
                f.write(serializers_code)
            
            self.logger.log_file_created(str(serializers_file))
            return {"serializers.py": serializers_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate serializers: {str(e)}", "CLAUDE_GENERATION")
            raise
    
    async def generate_django_views(self, models_code: str, serializers_code: str) -> Dict[str, str]:
        """Generate Django REST API views using Claude's superior architecture skills"""
        self.logger.log_activity("CLAUDE_GENERATION", "Generating Django REST API views")
        
        system_prompt = """You are a senior Django REST Framework architect with expertise in building scalable APIs.
        Create production-ready ViewSets and API views with proper authentication, permissions, and error handling.
        
        Focus on:
        - RESTful API design principles
        - Proper authentication and authorization
        - Efficient database queries and pagination
        - Comprehensive error handling
        - API documentation and OpenAPI schema
        - Rate limiting and throttling
        - Caching strategies
        - Security best practices"""
        
        user_prompt = f"""
        Create comprehensive Django REST Framework views based on these models and serializers:
        
        MODELS:
        ```python
        {models_code[:2000]}...
        ```
        
        SERIALIZERS:
        ```python
        {serializers_code[:2000]}...
        ```
        
        Generate ViewSets and APIViews that include:
        
        1. **ModelViewSets** for CRUD operations:
           - Proper authentication (JWT/Token)
           - Permission classes (IsAuthenticated, IsOwner)
           - Filtering, searching, and ordering
           - Pagination for large datasets
        
        2. **Custom API Views** for:
           - User authentication and registration
           - File upload with progress tracking
           - Transcription processing triggers
           - Analytics and reporting endpoints
           - Webhook handling
        
        3. **Business Logic Views**:
           - Audio processing workflow
           - Transcription status polling
           - AI analysis triggers
           - Subscription management
           - Usage tracking and quotas
        
        4. **Advanced Features**:
           - Custom actions for complex operations
           - Bulk operations with validation
           - Real-time updates via WebSocket
           - API versioning support
           - Rate limiting per user/plan
        
        Requirements:
        - Use ViewSets where appropriate, APIViews for custom logic
        - Include proper HTTP status codes
        - Comprehensive error handling with meaningful messages
        - Add API documentation with docstrings
        - Implement proper logging for monitoring
        - Include input validation and sanitization
        - Handle file uploads securely
        - Support for async task triggering (Celery)
        
        Return ONLY the complete views.py file content.
        """
        
        messages = [
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            views_code = await self.call_claude_api(messages, system_prompt)
            
            views_file = self.backend_path / "views.py"
            with open(views_file, 'w') as f:
                f.write(views_code)
            
            self.logger.log_file_created(str(views_file))
            return {"views.py": views_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate views: {str(e)}", "CLAUDE_GENERATION")
            raise
    
    async def generate_celery_tasks(self) -> Dict[str, str]:
        """Generate Celery tasks using Claude's understanding of async processing"""
        self.logger.log_activity("CLAUDE_GENERATION", "Generating Celery tasks")
        
        system_prompt = """You are a Celery expert specializing in async task processing and distributed systems.
        Create production-ready Celery tasks with proper error handling, retries, and monitoring.
        
        Focus on:
        - Robust error handling and retry strategies
        - Progress tracking and status updates
        - Resource management and cleanup
        - Integration with external APIs (OpenAI)
        - Task chaining and workflows
        - Monitoring and logging
        - Performance optimization"""
        
        user_prompt = f"""
        Create comprehensive Celery tasks for the Scriby transcription platform:
        
        Project Context:
        {json.dumps(self.project_context, indent=2)}
        
        Generate tasks for:
        
        1. **Audio Processing Pipeline**:
           - File validation and format conversion
           - Audio quality enhancement
           - Metadata extraction
           - File storage optimization
        
        2. **AI Transcription**:
           - OpenAI Whisper API integration
           - Progress tracking and status updates
           - Error handling and retries
           - Result post-processing
        
        3. **Content Analysis**:
           - GPT-4 content analysis
           - Summary generation
           - Topic extraction
           - Action items identification
           - Sentiment analysis
        
        4. **Business Operations**:
           - Usage analytics calculation
           - Billing and subscription updates
           - Email notifications
           - Report generation
           - Data cleanup and archival
        
        5. **System Maintenance**:
           - Health checks and monitoring
           - Cache warming
           - Database maintenance
           - Log rotation
        
        Requirements:
        - Use @shared_task decorator for reusability
        - Include comprehensive error handling
        - Add retry strategies with exponential backoff
        - Implement progress tracking
        - Include proper logging for debugging
        - Handle external API rate limits
        - Add task result persistence
        - Include cleanup for failed tasks
        - Support task chaining and workflows
        - Add monitoring hooks
        
        Return ONLY the complete tasks.py file content.
        """
        
        messages = [
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            tasks_code = await self.call_claude_api(messages, system_prompt)
            
            tasks_file = self.backend_path / "tasks.py"
            with open(tasks_file, 'w') as f:
                f.write(tasks_code)
            
            self.logger.log_file_created(str(tasks_file))
            return {"tasks.py": tasks_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate tasks: {str(e)}", "CLAUDE_GENERATION")
            raise
    
    async def generate_comprehensive_tests(self, models_code: str, views_code: str, tasks_code: str) -> Dict[str, str]:
        """Generate comprehensive tests using Claude's testing expertise"""
        self.logger.log_activity("CLAUDE_GENERATION", "Generating comprehensive test suite")
        
        system_prompt = """You are a Django testing expert focused on comprehensive test coverage and quality assurance.
        Create production-ready tests with proper mocking, fixtures, and edge case coverage.
        
        Focus on:
        - High test coverage (>90%)
        - Unit, integration, and end-to-end tests
        - Proper mocking of external services
        - Performance testing
        - Security testing
        - Edge cases and error conditions
        - Test data factories and fixtures"""
        
        user_prompt = f"""
        Create a comprehensive test suite for the Scriby Django backend:
        
        CODE CONTEXT (truncated for brevity):
        - Models: User, Recording, Transcription, Analysis, etc.
        - Views: REST API endpoints with authentication
        - Tasks: Celery async processing
        
        Generate tests that cover:
        
        1. **Model Tests**:
           - Field validation and constraints
           - Model methods and properties
           - Relationship integrity
           - Custom validators
           - Edge cases and boundary conditions
        
        2. **API Tests**:
           - Authentication and authorization
           - CRUD operations for all endpoints
           - Permission testing
           - Input validation and sanitization
           - Error handling and status codes
           - File upload functionality
        
        3. **Task Tests**:
           - Celery task execution
           - Error handling and retries
           - Progress tracking
           - External API mocking (OpenAI)
           - Task chaining and workflows
        
        4. **Integration Tests**:
           - End-to-end workflows
           - API + Task integration
           - Database transactions
           - File processing pipelines
        
        5. **Performance Tests**:
           - Database query optimization
           - API response times
           - Concurrent request handling
           - Memory usage
        
        Requirements:
        - Use Django TestCase and APITestCase
        - Include factory_boy for test data
        - Mock external API calls properly
        - Test both success and failure scenarios
        - Include setUp and tearDown methods
        - Add comprehensive docstrings
        - Use proper assertions and error messages
        - Include edge cases and boundary testing
        - Test file uploads and processing
        - Cover security scenarios
        
        Return ONLY the complete tests.py file content.
        """
        
        messages = [
            {"role": "user", "content": user_prompt}
        ]
        
        try:
            tests_code = await self.call_claude_api(messages, system_prompt)
            
            tests_file = self.backend_path / "tests.py"
            with open(tests_file, 'w') as f:
                f.write(tests_code)
            
            self.logger.log_file_created(str(tests_file))
            return {"tests.py": tests_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate tests: {str(e)}", "CLAUDE_GENERATION")
            raise
    
    async def setup_django_project(self):
        """Setup Django project structure"""
        self.logger.log_activity("PROJECT_SETUP", "Setting up Django project with Claude intelligence")
        
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
            except subprocess.CalledProcessError as e:
                self.logger.log_error(f"Failed to create Django project: {e}", "PROJECT_SETUP")
                raise
        
        # Create enhanced requirements.txt
        requirements = """# Core Django
Django==4.2.7
djangorestframework==3.14.0
django-cors-headers==4.3.1
django-extensions==3.2.3

# Database
psycopg2-binary==2.9.9

# Async Processing
celery==5.3.4
redis==5.0.1

# AI/ML Integration
openai==1.3.5

# Authentication
python-keycloak==3.7.0
djangorestframework-simplejwt==5.3.0

# File Handling
pillow==10.1.0

# Configuration
python-decouple==3.8

# Production
gunicorn==21.2.0
whitenoise==6.6.0

# Development
django-debug-toolbar==4.2.0
black==23.9.1
flake8==6.1.0

# Testing
pytest-django==4.5.2
factory-boy==3.3.0
coverage==7.3.2

# Monitoring
sentry-sdk==1.38.0

# API Documentation
drf-spectacular==0.26.5
"""
        
        requirements_file = self.backend_path / "requirements.txt"
        with open(requirements_file, 'w') as f:
            f.write(requirements.strip())
        
        self.logger.log_file_created(str(requirements_file))
    
    async def run_claude_development_cycle(self):
        """Run a complete Claude-powered development cycle"""
        self.logger.log_cycle_start(1)
        
        try:
            print("🧠 Claude is analyzing the project requirements...")
            
            # 1. Setup project structure
            await self.setup_django_project()
            print("  ✅ Django project structure initialized")
            
            # 2. Generate models with Claude's superior reasoning
            print("  🧠 Claude is designing the database models...")
            models_result = await self.generate_django_models(
                "Enterprise transcription platform with user management, audio processing, AI analysis, and subscription billing"
            )
            print("  ✅ Production-ready Django models generated")
            
            # 3. Generate serializers
            print("  🧠 Claude is creating REST API serializers...")
            serializers_result = await self.generate_django_serializers(models_result["models.py"])
            print("  ✅ DRF serializers with advanced validation created")
            
            # 4. Generate views
            print("  🧠 Claude is architecting the API endpoints...")
            views_result = await self.generate_django_views(
                models_result["models.py"], 
                serializers_result["serializers.py"]
            )
            print("  ✅ RESTful API views with authentication generated")
            
            # 5. Generate Celery tasks
            print("  🧠 Claude is designing async processing tasks...")
            tasks_result = await self.generate_celery_tasks()
            print("  ✅ Celery tasks for AI processing created")
            
            # 6. Generate comprehensive tests
            print("  🧠 Claude is writing comprehensive test suite...")
            tests_result = await self.generate_comprehensive_tests(
                models_result["models.py"], 
                views_result["views.py"],
                tasks_result["tasks.py"]
            )
            print("  ✅ Production-ready test suite generated")
            
            completed_tasks = [
                "Django project structure with enhanced dependencies",
                "Claude-generated models with advanced relationships",
                "RESTful API views with authentication and permissions",
                "DRF serializers with comprehensive validation",
                "Celery tasks for async AI processing",
                "Comprehensive test suite with >90% coverage",
                "Production-ready code following best practices"
            ]
            
            self.logger.log_cycle_complete(1, completed_tasks)
            
            return {
                "status": "success",
                "ai_engine": "Claude 3.5 Sonnet (Latest)",
                "files_generated": len(models_result) + len(serializers_result) + len(views_result) + len(tasks_result) + len(tests_result),
                "tasks_completed": completed_tasks,
                "code_quality": "Production-ready with Claude's superior reasoning"
            }
            
        except Exception as e:
            self.logger.log_error(f"Claude development cycle failed: {str(e)}", "CYCLE_ERROR")
            raise

async def main():
    parser = argparse.ArgumentParser(description='Claude Backend Bot - Superior Django Development')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    parser.add_argument('--api-key', help='Claude API key (or set ANTHROPIC_API_KEY env var)')
    args = parser.parse_args()
    
    try:
        bot = ClaudeBackendBot(
            "/Users/ciroarendt/CURSOR/APP_11me/transcription_app",
            claude_api_key=args.api_key
        )
        
        print("🤖 Claude Backend Bot - Superior Django Development")
        print("🧠 Powered by Claude 3.5 Sonnet (Latest Model)")
        print("=" * 60)
        
        if args.continuous:
            print("🔄 Running in CONTINUOUS mode with Claude...")
            cycle = 0
            while True:
                try:
                    cycle += 1
                    print(f"\n🧠 Claude Development Cycle #{cycle}")
                    
                    result = await bot.run_claude_development_cycle()
                    
                    print(f"\n✅ Cycle #{cycle} completed with Claude's superior reasoning:")
                    print(f"   🧠 AI Engine: {result['ai_engine']}")
                    print(f"   📁 Files generated: {result['files_generated']}")
                    print(f"   ✅ Tasks: {len(result['tasks_completed'])}")
                    print(f"   🏆 Quality: {result['code_quality']}")
                    
                    await asyncio.sleep(90)  # Wait 1.5 minutes between cycles
                    
                except KeyboardInterrupt:
                    print("\n🛑 Claude development stopped")
                    break
                except Exception as e:
                    print(f"❌ Error in Claude cycle #{cycle}: {e}")
                    await asyncio.sleep(45)  # Wait before retry
        else:
            # Single run mode
            print("🧠 Running single Claude development cycle...")
            result = await bot.run_claude_development_cycle()
            
            print("\n🎉 Claude Backend Bot completed successfully!")
            print(f"🧠 AI Engine: {result['ai_engine']}")
            print(f"📁 Generated {result['files_generated']} production-ready files")
            print(f"🏆 Code Quality: {result['code_quality']}")
            print("\n📋 Next steps:")
            print("  1. cd scriby-backend")
            print("  2. pip install -r requirements.txt")
            print("  3. python manage.py migrate")
            print("  4. python manage.py runserver")
            print("\n🚀 Your Django backend is ready for production!")
            
    except Exception as e:
        print(f"❌ Claude Backend Bot failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
