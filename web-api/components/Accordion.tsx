import React, { useState } from "react";

const Accordion: React.FunctionComponent<{ header: React.ReactElement<any>; body: React.ReactElement<any> }> = ({
  header,
  body
}) => {
  const [isExpanded, setIsExpanded] = useState(false);

  function updateState() {
    console.log(isExpanded);
    setIsExpanded(!isExpanded);
  }

  return (
    <div>
      <div onClick={() => updateState()}>{header}</div>
      <div>{isExpanded ? <>{body}</> : <></>}</div>
    </div>
  );
};

export default Accordion;
