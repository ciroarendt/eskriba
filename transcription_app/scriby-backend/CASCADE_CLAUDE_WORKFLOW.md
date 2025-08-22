# Cascade-Claude Development Workflow

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
