# Generated to fix user field migration issues

import uuid
from django.conf import settings
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
        ('recordings', '0001_initial'),
    ]

    operations = [
        # Drop and recreate the table with correct structure
        migrations.RunSQL(
            "DROP TABLE IF EXISTS recordings_recording CASCADE;",
            reverse_sql="SELECT 1;"
        ),
        migrations.RunSQL(
            "DROP TABLE IF EXISTS recordings_transcription CASCADE;",
            reverse_sql="SELECT 1;"
        ),
        migrations.RunSQL(
            "DROP TABLE IF EXISTS recordings_analysis CASCADE;",
            reverse_sql="SELECT 1;"
        ),
        
        # Recreate tables with correct structure
        migrations.CreateModel(
            name='Recording',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('title', models.CharField(max_length=200)),
                ('audio_file', models.FileField(upload_to='recordings/')),
                ('duration', models.DurationField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('status', models.CharField(default='uploaded', max_length=20)),
                ('user', models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.CASCADE, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='Transcription',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('text', models.TextField()),
                ('confidence_score', models.FloatField(blank=True, null=True)),
                ('processing_time', models.DurationField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('recording', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to='recordings.recording')),
            ],
        ),
        migrations.CreateModel(
            name='Analysis',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('summary', models.TextField()),
                ('key_topics', models.JSONField(default=list)),
                ('action_items', models.JSONField(default=list)),
                ('sentiment_score', models.FloatField(blank=True, null=True)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('transcription', models.OneToOneField(on_delete=django.db.models.deletion.CASCADE, to='recordings.transcription')),
            ],
        ),
    ]
