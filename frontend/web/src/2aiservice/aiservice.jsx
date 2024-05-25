import './aiservice.css';
import React from 'react';
import Header from '../0header/header';

export default function AIService() {

  return (
    <div className="Main">
      <Header/>
      <main className='aiservice-container'>
        <div className='dataset'>
          <h2>학습 데이터셋</h2>
          <a href="https://www.naver.com" target="_blank" rel="noopener noreferrer">
            대화분류(AIhub)
          </a>
          <a href="https://www.naver.com" target="_blank" rel="noopener noreferrer">
            연속적 대화(AIhub)
          </a>
          <div>
            커스텀(extra)
          </div>
        </div>
        <div className='add-custom-data'>
          <h2>커스텀데이터 추가</h2>
          <form>
            <input type="text" name="sentence" placeholder="문장 입력" />
            <select name="emotion">
              <option value="행복">행복</option>
              <option value="놀람">놀람</option>
              <option value="짜증">짜증</option>
              <option value="슬픔">슬픔</option>
              <option value="불안">불안</option>
              <option value="분노">분노</option>
              <option value="중립">중립</option>
            </select>
            <button type="submit">추가하기</button>
          </form>
        </div>
        <div className='model-select'>
          <h2>모델 버전 선택</h2>
          <form>
            <label className="radio-label">
              <input type="radio" name="model" value="Koelectra 0.86" />
              Koelectra 0.86
            </label>
            <label className="radio-label">
              <input type="radio" name="model" value="Kobert" />
              Kobert
            </label>
            <label className="radio-label">
              <input type="radio" name="model" value="Koelect 0.7" />
              Koelect 0.7
            </label>
          </form>
        </div>
      </main>
    </div>
  );
}