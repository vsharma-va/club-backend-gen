from configparser import ConfigParser
from supabase import create_client, Client

parser = ConfigParser()
parser.read("api.config")
supabase: Client = create_client(parser['SUPABASE']['url'], parser['SUPABASE']['key'])
