from supabase import Client, PostgrestAPIResponse

class Supa:
    def __init__(self, supabase: Client) -> None:
        self.supabase = supabase
        
    def locate_in_admin(self, user_id: str) -> PostgrestAPIResponse:
        return self.supabase.table("admin_table").select("*").eq("user_id", f"{user_id}").execute()