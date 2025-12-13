"""
Schemas Pydantic pour User
"""
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime
from uuid import UUID


class UserBase(BaseModel):
    """Schéma de base pour User"""
    email: EmailStr
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class UserCreate(UserBase):
    """Schéma pour créer un utilisateur"""
    password: str = Field(..., min_length=8)


class UserUpdate(BaseModel):
    """Schéma pour mettre à jour un utilisateur"""
    first_name: Optional[str] = None
    last_name: Optional[str] = None


class UserInDB(UserBase):
    """Schéma User en base de données"""
    id: UUID
    is_active: bool
    created_at: datetime
    updated_at: datetime
    last_login: Optional[datetime] = None
    
    class Config:
        from_attributes = True


class User(UserInDB):
    """Schéma User public (sans informations sensibles)"""
    pass


class Token(BaseModel):
    """Schéma pour le token JWT"""
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseModel):
    """Données du token"""
    user_id: Optional[str] = None


class UserLogin(BaseModel):
    """Schéma pour la connexion"""
    email: EmailStr
    password: str

