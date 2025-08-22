#!/usr/bin/env python3
"""
AI Backend Bot - Real Django Development with OpenAI
Generates actual Django code using GPT-4, creates files, and manages development workflow
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

class AIBackendBot:
    def __init__(self, project_path: str, openai_api_key: str = None):
        self.project_path = Path(project_path)
        self.backend_path = self.project_path / 'scriby-backend'
        self.logger = create_bot_logger('ai-backend', str(self.project_path))
        
        # OpenAI Configuration
        self.openai_api_key = openai_api_key or os.getenv('OPENAI_API_KEY')
        if not self.openai_api_key:
            raise ValueError("OpenAI API key is required. Set OPENAI_API_KEY environment variable.")
        
        self.openai_base_url = "https://api.openai.com/v1"
        self.model = "gpt-4"
        
        # Development context
        self.project_context = {
            "name": "Scriby",
            "description": "AI-powered transcription and meeting analysis app",
            "tech_stack": ["Django", "DRF", "Celery", "Redis", "PostgreSQL", "OpenAI"],
            "features": ["audio recording", "transcription", "AI analysis", "user management"]
        }
        
    async def call_openai_api(self, messages: List[Dict], temperature: float = 0.3) -> str:
        """Make async call to OpenAI API"""
        headers = {
            "Authorization": f"Bearer {self.openai_api_key}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": self.model,
            "messages": messages,
            "temperature": temperature,
            "max_tokens": 4000
        }
        
        async with aiohttp.ClientSession() as session:
            async with session.post(
                f"{self.openai_base_url}/chat/completions",
                headers=headers,
                json=payload
            ) as response:
                if response.status == 200:
                    data = await response.json()
                    return data['choices'][0]['message']['content']
                else:
                    error = await response.text()
                    raise Exception(f"OpenAI API error: {error}")
    
    async def generate_django_models(self, requirements: str) -> Dict[str, str]:
        """Generate Django models using AI"""
        self.logger.log_activity("AI_GENERATION", f"Generating Django models for: {requirements}")
        
        prompt = f"""
        Generate Django models for the Scriby transcription app based on these requirements:
        {requirements}
        
        Context:
        - App name: Scriby
        - Purpose: Audio transcription and AI analysis
        - Tech stack: Django, DRF, Celery, Redis, PostgreSQL
        
        Generate models for:
        1. User management (extend AbstractUser)
        2. Audio recordings
        3. Transcriptions
        4. AI analysis results
        5. User subscriptions/plans
        
        Requirements:
        - Follow Django best practices
        - Include proper relationships
        - Add appropriate indexes
        - Include created_at/updated_at fields
        - Add proper __str__ methods
        - Include model validation
        
        Return ONLY the Python code for models.py, no explanations.
        """
        
        messages = [
            {"role": "system", "content": "You are an expert Django developer. Generate clean, production-ready Django models."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            models_code = await self.call_openai_api(messages)
            
            # Save to file
            models_file = self.backend_path / "models.py"
            models_file.parent.mkdir(parents=True, exist_ok=True)
            
            with open(models_file, 'w') as f:
                f.write(models_code)
            
            self.logger.log_file_created(str(models_file))
            self.logger.log_activity("AI_SUCCESS", f"Generated Django models: {models_file}")
            
            return {"models.py": models_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate models: {str(e)}", "AI_GENERATION")
            raise
    
    async def generate_django_views(self, models_code: str) -> Dict[str, str]:
        """Generate Django REST API views"""
        self.logger.log_activity("AI_GENERATION", "Generating Django REST API views")
        
        prompt = f"""
        Based on these Django models, generate Django REST Framework views:
        
        {models_code}
        
        Generate:
        1. ViewSets for all models
        2. Custom actions for transcription processing
        3. Authentication and permissions
        4. Filtering and pagination
        5. Error handling
        6. API documentation with docstrings
        
        Requirements:
        - Use Django REST Framework ViewSets
        - Include proper permissions (IsAuthenticated, IsOwner)
        - Add filtering, searching, ordering
        - Include custom actions for business logic
        - Proper error handling and responses
        - Follow DRF best practices
        
        Return ONLY the Python code for views.py, no explanations.
        """
        
        messages = [
            {"role": "system", "content": "You are an expert Django REST Framework developer."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            views_code = await self.call_openai_api(messages)
            
            views_file = self.backend_path / "views.py"
            with open(views_file, 'w') as f:
                f.write(views_code)
            
            self.logger.log_file_created(str(views_file))
            return {"views.py": views_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate views: {str(e)}", "AI_GENERATION")
            raise
    
    async def generate_serializers(self, models_code: str) -> Dict[str, str]:
        """Generate Django REST serializers"""
        self.logger.log_activity("AI_GENERATION", "Generating DRF serializers")
        
        prompt = f"""
        Based on these Django models, generate Django REST Framework serializers:
        
        {models_code}
        
        Generate:
        1. ModelSerializers for all models
        2. Nested serializers for relationships
        3. Custom validation methods
        4. Read-only and write-only fields
        5. Custom fields for file uploads
        
        Requirements:
        - Use ModelSerializer where appropriate
        - Include proper field validation
        - Handle file uploads for audio files
        - Nested serialization for related objects
        - Custom to_representation methods if needed
        
        Return ONLY the Python code for serializers.py, no explanations.
        """
        
        messages = [
            {"role": "system", "content": "You are an expert Django REST Framework developer."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            serializers_code = await self.call_openai_api(messages)
            
            serializers_file = self.backend_path / "serializers.py"
            with open(serializers_file, 'w') as f:
                f.write(serializers_code)
            
            self.logger.log_file_created(str(serializers_file))
            return {"serializers.py": serializers_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate serializers: {str(e)}", "AI_GENERATION")
            raise
    
    async def generate_celery_tasks(self) -> Dict[str, str]:
        """Generate Celery tasks for async processing"""
        self.logger.log_activity("AI_GENERATION", "Generating Celery tasks")
        
        prompt = f"""
        Generate Celery tasks for the Scriby transcription app:
        
        Context: {json.dumps(self.project_context, indent=2)}
        
        Generate tasks for:
        1. Audio file processing and validation
        2. OpenAI Whisper transcription
        3. GPT-4 analysis (summary, topics, action items)
        4. Email notifications
        5. File cleanup and optimization
        6. Usage analytics and reporting
        
        Requirements:
        - Use Celery decorators (@shared_task)
        - Include proper error handling and retries
        - Add progress tracking
        - Include logging for monitoring
        - Handle file operations safely
        - Integrate with OpenAI API
        
        Return ONLY the Python code for tasks.py, no explanations.
        """
        
        messages = [
            {"role": "system", "content": "You are an expert Celery developer with OpenAI integration experience."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            tasks_code = await self.call_openai_api(messages)
            
            tasks_file = self.backend_path / "tasks.py"
            with open(tasks_file, 'w') as f:
                f.write(tasks_code)
            
            self.logger.log_file_created(str(tasks_file))
            return {"tasks.py": tasks_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate tasks: {str(e)}", "AI_GENERATION")
            raise
    
    async def generate_tests(self, models_code: str, views_code: str) -> Dict[str, str]:
        """Generate comprehensive tests"""
        self.logger.log_activity("AI_GENERATION", "Generating unit tests")
        
        prompt = f"""
        Generate comprehensive Django tests based on these models and views:
        
        MODELS:
        {models_code[:1000]}...
        
        VIEWS:
        {views_code[:1000]}...
        
        Generate:
        1. Model tests (validation, methods, relationships)
        2. API endpoint tests (CRUD operations)
        3. Authentication tests
        4. Permission tests
        5. Integration tests for Celery tasks
        6. File upload tests
        
        Requirements:
        - Use Django TestCase and APITestCase
        - Include setUp and tearDown methods
        - Test both success and failure scenarios
        - Mock external API calls (OpenAI)
        - Test file uploads and processing
        - Include edge cases and validation tests
        
        Return ONLY the Python code for tests.py, no explanations.
        """
        
        messages = [
            {"role": "system", "content": "You are an expert Django test developer focused on comprehensive test coverage."},
            {"role": "user", "content": prompt}
        ]
        
        try:
            tests_code = await self.call_openai_api(messages)
            
            tests_file = self.backend_path / "tests.py"
            with open(tests_file, 'w') as f:
                f.write(tests_code)
            
            self.logger.log_file_created(str(tests_file))
            return {"tests.py": tests_code}
            
        except Exception as e:
            self.logger.log_error(f"Failed to generate tests: {str(e)}", "AI_GENERATION")
            raise
    
    async def setup_django_project(self):
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
            except subprocess.CalledProcessError as e:
                self.logger.log_error(f"Failed to create Django project: {e}", "PROJECT_SETUP")
                raise
        
        # Create requirements.txt with AI-enhanced dependencies
        requirements = """
Django==4.2.7
djangorestframework==3.14.0
celery==5.3.4
redis==5.0.1
psycopg2-binary==2.9.9
openai==1.3.5
python-keycloak==3.7.0
django-cors-headers==4.3.1
pillow==10.1.0
python-decouple==3.8
gunicorn==21.2.0
django-extensions==3.2.3
django-debug-toolbar==4.2.0
pytest-django==4.5.2
factory-boy==3.3.0
coverage==7.3.2
black==23.9.1
flake8==6.1.0
"""
        
        requirements_file = self.backend_path / "requirements.txt"
        with open(requirements_file, 'w') as f:
            f.write(requirements.strip())
        
        self.logger.log_file_created(str(requirements_file))
    
    async def run_development_cycle(self):
        """Run a complete AI-powered development cycle"""
        self.logger.log_cycle_start(1)
        
        try:
            # 1. Setup project structure
            await self.setup_django_project()
            
            # 2. Generate models with AI
            models_result = await self.generate_django_models(
                "User management, audio recordings, transcriptions, AI analysis, subscriptions"
            )
            
            # 3. Generate serializers
            serializers_result = await self.generate_serializers(models_result["models.py"])
            
            # 4. Generate views
            views_result = await self.generate_django_views(models_result["models.py"])
            
            # 5. Generate Celery tasks
            tasks_result = await self.generate_celery_tasks()
            
            # 6. Generate tests
            tests_result = await self.generate_tests(
                models_result["models.py"], 
                views_result["views.py"]
            )
            
            completed_tasks = [
                "Django project structure created",
                "AI-generated models with relationships",
                "REST API views and endpoints",
                "Serializers with validation",
                "Celery tasks for async processing",
                "Comprehensive test suite"
            ]
            
            self.logger.log_cycle_complete(1, completed_tasks)
            
            return {
                "status": "success",
                "files_generated": len(models_result) + len(serializers_result) + len(views_result) + len(tasks_result) + len(tests_result),
                "tasks_completed": completed_tasks
            }
            
        except Exception as e:
            self.logger.log_error(f"Development cycle failed: {str(e)}", "CYCLE_ERROR")
            raise

async def main():
    parser = argparse.ArgumentParser(description='AI Backend Bot - Real Django Development')
    parser.add_argument('--continuous', action='store_true', help='Run in continuous mode')
    parser.add_argument('--api-key', help='OpenAI API key (or set OPENAI_API_KEY env var)')
    args = parser.parse_args()
    
    try:
        bot = AIBackendBot(
            "/Users/ciroarendt/CURSOR/APP_11me/transcription_app",
            openai_api_key=args.api_key
        )
        
        print("🤖 AI Backend Bot - Real Django Development with OpenAI")
        print("=" * 60)
        
        if args.continuous:
            print("🔄 Running in CONTINUOUS mode with AI...")
            cycle = 0
            while True:
                try:
                    cycle += 1
                    print(f"\n🧠 AI Development Cycle #{cycle}")
                    
                    result = await bot.run_development_cycle()
                    
                    print(f"✅ Cycle #{cycle} completed:")
                    print(f"   📁 Files generated: {result['files_generated']}")
                    print(f"   ✅ Tasks: {len(result['tasks_completed'])}")
                    
                    await asyncio.sleep(60)  # Wait 1 minute between cycles
                    
                except KeyboardInterrupt:
                    print("\n🛑 AI development stopped")
                    break
                except Exception as e:
                    print(f"❌ Error in AI cycle #{cycle}: {e}")
                    await asyncio.sleep(30)  # Wait before retry
        else:
            # Single run mode
            print("🧠 Running single AI development cycle...")
            result = await bot.run_development_cycle()
            
            print("\n🎉 AI Backend Bot completed successfully!")
            print(f"📁 Generated {result['files_generated']} files")
            print("\n📋 Next steps:")
            print("  1. cd scriby-backend")
            print("  2. pip install -r requirements.txt")
            print("  3. python manage.py migrate")
            print("  4. python manage.py runserver")
            
    except Exception as e:
        print(f"❌ AI Backend Bot failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())
