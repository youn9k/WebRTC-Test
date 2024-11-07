import Vapor

func routes(_ app: Application) throws {
    var connections = [WebSocket]()
    
    // WebSocket 연결을 처리하는 라우트
    app.webSocket("signaling") { req, ws in
        connections.append(ws)
        
        // 클라이언트가 연결될 때 호출
        print("Client connected. Total connected clients: \(connections.count)")

        // 모든 클라이언트에게 메시지를 브로드캐스트하는 함수 정의
        func broadcast(message: String, except ws: WebSocket) {
            connections.forEach { connection in
                if connection !== ws {
                    connection.send(message)
                }
            }
        }

        // 클라이언트로부터 메시지를 수신할 때 호출
        ws.onText { ws, text in
            print("Received message: \(text)")
            broadcast(message: text, except: ws)
        }

        // 클라이언트가 연결을 종료할 때 호출
        ws.onClose.whenComplete { _ in
            connections.removeAll { $0 === ws }
            print("Client disconnected. Total connected clients: \(connections.count)")
        }
    }
}
