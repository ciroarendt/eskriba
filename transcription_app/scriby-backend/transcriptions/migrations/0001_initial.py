# Generated to create Transcription model in transcriptions app

import uuid
from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('recordings', '0002_fix_user_field'),
    ]

    operations = [
        migrations.CreateModel(
            name='Transcription',
            fields=[
                ('id', models.UUIDField(default=uuid.uuid4, editable=False, primary_key=True, serialize=False)),
                ('text', models.TextField(blank=True, null=True)),
                ('language', models.CharField(choices=[('en', 'English'), ('es', 'Spanish'), ('pt', 'Portuguese'), ('fr', 'French'), ('de', 'German'), ('it', 'Italian'), ('auto', 'Auto-detect')], default='auto', max_length=10)),
                ('confidence_score', models.FloatField(blank=True, null=True)),
                ('status', models.CharField(choices=[('pending', 'Pending'), ('processing', 'Processing'), ('completed', 'Completed'), ('failed', 'Failed')], default='pending', max_length=20)),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('updated_at', models.DateTimeField(auto_now=True)),
                ('recording', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='transcriptions', to='recordings.recording')),
            ],
            options={
                'verbose_name': 'Transcription',
                'verbose_name_plural': 'Transcriptions',
                'ordering': ['-created_at'],
            },
        ),
    ]
