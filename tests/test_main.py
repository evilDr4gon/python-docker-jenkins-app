from app.main import app

def test_hello_world():
    client = app.test_client()
    response = client.get("/")
    assert response.status_code == 200
    assert response.data == b"Hola Mundo!"

def test_ping():
    client = app.test_client()
    response = client.get("/ping")
    assert response.status_code == 200
    assert response.data == b"Pong!"

