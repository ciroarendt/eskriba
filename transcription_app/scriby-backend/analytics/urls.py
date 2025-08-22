"""
Analytics URLs for Eskriba backend.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
router.register(r'usage', views.UsageAnalyticsViewSet)

urlpatterns = [
    path('', include(router.urls)),
    path('dashboard/', views.DashboardAnalyticsView.as_view(), name='dashboard-analytics'),
    path('costs/', views.CostAnalyticsView.as_view(), name='cost-analytics'),
    path('aarrr/', views.AARRRMetricsView.as_view(), name='aarrr-metrics'),
]
