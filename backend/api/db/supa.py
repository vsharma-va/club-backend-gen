from supabase import Client, PostgrestAPIResponse
import datetime
from global_var import parser
import jwt


class Supa:
    def __init__(self, supabase: Client) -> None:
        self.supabase = supabase

    def locate_in_admin(self, user_id: str) -> PostgrestAPIResponse:
        return (
            self.supabase.table("admin_table")
            .select("*")
            .eq("user_id", f"{user_id}")
            .execute()
        )
        
    def fetch_active_qr(self, user_id: str):
        response = (
            self.supabase.table("track_user_table")
            .select("*")
            .eq("user_id", f"{user_id}")
            .eq("is_expired", False)
            .execute()
        )
        if len(response.data) == 0:
            return {
                "status": 404,
                "detail": {"msg": "user has no active registerations"},
            }
        else:
            return {
                "status": 200,
                "detail": {"msg": "Success", "jwt_qr": response.data[0]["jwt_qr"]},
            }

    def sign_in_app_procedure(self, app_user_auth_key: str):
        response = (
            self.supabase.table("app_user_table")
            .select("*")
            .eq("auth_key", app_user_auth_key)
            .execute()
        )
        if len(response.data) == 0:
            return {"status": 401, "detail": {"msg": "wrong auth key"}}
        else:
            return {
                "status": 200,
                "detail": {
                    "msg": "logged in successfully",
                    "user_state": response.data[0],
                },
            }

    def register_event_procedure(
        self,
        user_id: str,
        event_id: int,
        is_expired: bool = False,
        attended: bool = False,
    ):
        events_check = (
            self.supabase.table("events_table")
            .select("*")
            .eq("id", int(event_id))
            .execute()
        )
        if (
            len(events_check.data) == 1
            and events_check.data[0]["event_completed"] != True
            and events_check.data[0]["event_capacity"]
            > events_check.data[0]["number_registered"]
        ):
            check_qr_exists = (
                self.supabase.table("track_user_table")
                .select("*")
                .eq("user_id", user_id)
                .eq("event_id", event_id)
            ).execute()
            if len(check_qr_exists.data) == 0:
                to_encode = {
                    "user_id": user_id,
                    "event_id": event_id,
                    "nonce": "don't try and decode it!",
                }
                jwt_qr = jwt.encode(
                    to_encode, parser["EVENTS"]["secret_key"], algorithm="HS256"
                )
                response = (
                    self.supabase.table("track_user_table")
                    .insert(
                        {
                            "user_id": user_id,
                            "event_id": event_id,
                            "expires_on": str(datetime.datetime.now()),
                            "is_expired": is_expired,
                            "attended": attended,
                            "jwt_qr": jwt_qr,
                        }
                    )
                    .execute()
                )
                return {
                    "status": 200,
                    "detail": {
                        "msg": "success",
                        "jwt_qr": jwt_qr,
                    },
                }
            else:
                return {
                    "status": 200,
                    "detail": {
                        "msg": "user is already registered!",
                        "jwt_qr": check_qr_exists.data[0]["jwt_qr"],
                    },
                }
        else:
            return {"status": 422, "detail": {"msg": "requested event doesn't exist"}}

    def check_qr_procedure(self, jwt_qr):
        try:
            data = jwt.decode(
                jwt_qr, parser["EVENTS"]["secret_key"], algorithms=["HS256"]
            )
            check_attendance = (
                self.supabase.table("track_user_table")
                .select("*")
                .eq("attended", False)
                .eq("user_id", data["user_id"])
                .eq("event_id", data["event_id"])
            ).execute()
            if(len(check_attendance.data) != 0):
                response = (
                    self.supabase.table("track_user_table")
                    .update({"attended": True})
                    .eq("user_id", data["user_id"])
                    .eq("jwt_qr", jwt_qr)
                    .eq("event_id", data["event_id"])
                    .execute()
                )
                if len(response.data) != 0:
                    return {"status": 200, "detail": {"msg": "Confirmed Attendance"}}
                else:
                    return {
                        "status": 409,
                        "detail": {"msg": "Invalid QR or Attendance Already Confirmed"},
                    }
            else:
                return {
                    "status": 409, "detail": {"msg": "Attendance Already Confirmed"},
                }
        except jwt.DecodeError:
            return {"status": 422, "detail": {"msg": "Invalid JWT"}}
