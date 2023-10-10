from fastapi import APIRouter, Depends, Body
from pydantic import BaseModel
from routers.auth import auth as auth
import db.supa as supa
from global_var import supabase, supabaseAuthClient
from typing import Annotated

router = APIRouter()

class Qr(BaseModel):
    jwt_qr: str

@router.post("/event/register/{event_id}")
async def register_for_event(
    event_id: int, user_state: auth.UserAuthState = Depends(auth.check_auth_state)
):
    # check if event exists
    # add an entry in the track_user_table
    db_client = supa.Supa(supabase)
    response = db_client.register_event_procedure(
        user_id=user_state.supabase_id, event_id=int(event_id)
    )
    response["detail"]["user_state"] = user_state
    return response


@router.post("/event/fetch_qr")
async def fetch_qr(user_state: auth.UserAuthState = Depends(auth.check_auth_state)):
    db_client = supa.Supa(supabase)
    response = db_client.fetch_active_qr(user_state.supabase_id)
    response["detail"]["user_state"] = user_state
    return response


@router.post("/event/app/check_qr")
async def check_qr(app_user_auth_key: Annotated[str, Body()], jwt_qr: Annotated[str, Body()]):
    db_client = supa.Supa(supabase)
    response = db_client.sign_in_app_procedure(app_user_auth_key=app_user_auth_key)
    if response["status"] == 401:
        return response
    elif response["status"] == 200:
        response = db_client.check_qr_procedure(jwt_qr)
        return response
    
@router.post("/event/app/qr_details")
async def return_qr_details(qr: Qr):
    print(qr.jwt_qr)
    db_client = supa.Supa(supabaseAuthClient)
    response = db_client.return_qr_details_procedure(jwt_ar=qr.jwt_qr)
    return response
    


@router.get("/event/fetch")
async def get_all_events(
    user_state: auth.UserAuthState = Depends(auth.check_auth_state),
):
    # return all entries in events_table
    # add checks in frontend for whatever is required
    return {"status": 200, "detail": "nothing rn"}
