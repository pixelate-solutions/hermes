from pydantic import BaseModel, EmailStr, Field


class EnterpriseLeadIn(BaseModel):
    name: str = Field(min_length=2, max_length=255)
    email: EmailStr
    company: str = Field(min_length=2, max_length=255)
    use_case: str = Field(min_length=5, max_length=2000)
    desired_volume: str = Field(min_length=1, max_length=120)


class EnterpriseLeadOut(BaseModel):
    id: str
    message: str
