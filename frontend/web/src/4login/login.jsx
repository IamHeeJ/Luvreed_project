import React, { useState } from 'react';
import { useNavigate } from "react-router-dom";
import Header from '../0header/header';
import './login.css';

const Login = () => {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loginCheck, setLoginCheck] = useState(false);

  const navigate = useNavigate();

  const handleLogin = async (event) => {
    event.preventDefault();
    await new Promise((r) => setTimeout(r, 1000));
    
    const response = await fetch(
      "/api/web/login",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          email: email,
          password: password,
        }),
      }
    );
    const result = await response.json();

    if (response.status === 200) {
      setLoginCheck(false);
      // Store token in local storage
      sessionStorage.setItem("token", result.token);
      sessionStorage.setItem("email", result.email); // 여기서 email(로그인id)를 저장
      sessionStorage.setItem("role", result.role); // 여기서 role을 저장
      sessionStorage.setItem("id", result.Id); // 여기서 id를 저장
      sessionStorage.setItem("name", result.name); // 여기서 name을 저장
      console.log("로그인성공, 토큰:" + result.token);
      navigate("/manage"); // 로그인 성공시 회원관리 페이지로 이동
    } else {
      setLoginCheck(true);
    }
  };


  return (
    <div className="Main">
      <Header />
      <main className="login-container">
        <div className="login-form" onSubmit={handleLogin}>
          <h2>관리자 로그인</h2>
          <h4>관리자만 로그인이 가능합니다.</h4>
          <div className="input-group">
            <div className="inputarea">
              <input
                type="text"
                id="username"
                name="username"
                placeholder="관리자 아이디를 입력하세요."
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
            </div>
          </div>
          <div className="input-group">
            <div className="inputarea">
              <input
                type="password"
                id="password"
                name="password"
                placeholder="관리자 비밀번호를 입력하세요."
                value={password}
                onChange={(e) => setPassword(e.target.value)}
              />
            </div>
          </div>
          {loginCheck && (
        <label style={{color: "red"}}>이메일 혹은 비밀번호가 틀렸습니다.</label>
        )}
          <button type="button" className="login-button" onClick={handleLogin}>
            로그인하기
          </button>
        </div>
      </main>
    </div>
  );
};

export default Login;
