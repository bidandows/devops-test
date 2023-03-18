import { render } from '@testing-library/react';
import React from 'react';
import CommentList from './CommentList';

describe('Comment List', () => {
  it('Should render the component', () => {
    const wrapper = render(<CommentList comments={[{ content: 'hello, world' }]} />);
    expect(wrapper.getByText('hello, world')).not.toBe(null);
  });

  it('Should have only one comment', () => {
    const wrapper = render(<CommentList comments={[{ content: '' }]} />);
    const elements = wrapper.getAllByRole('list');
    expect(elements.length).toBe(1);
  });

  it('Should have find 10 comments', () => {
    const wrapper = render(
      <CommentList
        comments={Array(10)
          .fill({ content: '' })
          .map(e => ({ ...e, id: Math.random() * 0xffff }))}
      />
    );
    const elements = wrapper.getAllByRole('list');
    expect(elements.length).toBe(1);
  });

  it('Should find "This comment has been rejected" when the comment is rejected', () => {
    const wrapper = render(<CommentList comments={[{ content: 'Super comment', status: 'rejected' }]} />);
    expect(wrapper.getByText('This comment has been rejected')).not.toBe(null);
  });
});