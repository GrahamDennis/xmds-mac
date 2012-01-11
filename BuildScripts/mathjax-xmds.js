/*************************************************************
 *
 *  MathJax/config/default.js
 *
 *  This configuration file is loaded when you load MathJax
 *  via <script src="MathJax.js?config=default"></script>
 *
 *  Use it to customize the MathJax settings.  See comments below.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009-2011 Design Science, Inc.
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */


/*
 *  This file lists most, but not all, of the options that can be set for
 *  MathJax and its various components.  Some additional options are
 *  available, however, and are listed in the various links at:
 *  
 *  http://www.mathjax.org/resources/docs/?configuration.html#configuration-options-by-component
 *
 *  You can add these to the configuration object below if you 
 *  want to change them from their default values.
 */

MathJax.Hub.Config({
  //
  //  This value controls whether the "Processing Math: nn%" message are displayed
  //  in the lower left-hand corner.  Set to "false" to prevent those messages (though
  //  file loading and other messages will still be shown).
  //
  showProcessingMessages: true,
  
  //
  //  This value controls the verbosity of the messages in the lower left-hand corner.
  //  Set it to "none" to eliminate all messages, or set it to "simple" to show
  //  "Loading..." and "Processing..." rather than showing the full file name and the
  //  percentage of the mathematics processed.
  //
  messageStyle: "normal",
  
  //============================================================================
  //
  //  These parameters control the tex2jax preprocessor (when you have included
  //  "tex2jax.js" in the extensions list above).
  //
  tex2jax: {

    //
    //  The delimiters that surround in-line math expressions.  The first in each
    //  pair is the initial delimiter and the second is the terminal delimiter.
    //  Comment out any that you don't want, but be sure there is no extra
    //  comma at the end of the last item in the list -- some browsers won't
    //  be able to handle that.
    //
    inlineMath: [
//    ['$','$'],      // uncomment this for standard TeX math delimiters
      ['\\(','\\)']
    ],

    //
    //  The delimiters that surround displayed math expressions.  The first in each
    //  pair is the initial delimiter and the second is the terminal delimiter.
    //  Comment out any that you don't want, but be sure there is no extra
    //  comma at the end of the last item in the list -- some browsers won't
    //  be able to handle that.
    //
    displayMath: [
      ['$$','$$'],
      ['\\[','\\]']
    ],

    //
    //  This array lists the names of the tags whose contents should not be
    //  processed by tex2jax (other than to look for ignore/process classes
    //  as listed below).  You can add to (or remove from) this list to prevent
    //  MathJax from processing mathematics in specific contexts.
    //
    skipTags: ["script","noscript","style","textarea","pre","code"],

    //
    //  This is the class name used to mark elements whose contents should
    //  not be processed by tex2jax (other than to look for the
    //  processClass pattern below).  Note that this is a regular
    //  expression, and so you need to be sure to quote any regexp special
    //  characters.  The pattern is automatically preceeded by '(^| )(' and
    //  followed by ')( |$)', so your pattern will have to match full words
    //  in the class name.  Assigning an element this class name will
    //  prevent `tex2jax` from processing its contents.
    //
    ignoreClass: "tex2jax_ignore",

    //
    //  This is the class name used to mark elements whose contents SHOULD
    //  be processed by tex2jax.  This is used to turn on processing within
    //  tags that have been marked as ignored or skipped above.  Note that
    //  this is a regular expression, and so you need to be sure to quote
    //  any regexp special characters.  The pattern is automatically
    //  preceeded by '(^| )(' and followed by ')( |$)', so your pattern
    //  will have to match full words in the class name.  Use this to
    //  restart processing within an element that has been marked as
    //  ignored above.
    //
    processClass: "tex2jax_process",
    
    //
    //  Set to "true" to allow \$ to produce a dollar without starting in-line
    //  math mode.  If you uncomment the ['$','$'] line above, you should change
    //  this to true so that you can insert plain dollar signs into your documents
    //
    processEscapes: false,

    //
    //  Controls whether tex2jax processes LaTeX environments outside of math
    //  mode.  Set to "false" to prevent processing of environments except within
    //  math mode.
    //
    processEnvironments: true,

    //
    //  Controls whether tex2jax inserts MathJax_Preview spans to make a
    //  preview available, and what preview to use, when it locates in-line
    //  and display mathetics on the page.  The default is "TeX", which
    //  means use the TeX code as the preview (until it is processed by
    //  MathJax).  Set to "none" to prevent the previews from being
    //  inserted (the math will simply disappear until it is typeset).  Set
    //  to an array containing the description of an HTML snippet in order
    //  to use the same preview for all equations on the page (e.g., you
    //  could have it say "[math]" or load an image).
    //  
    //  E.g.,     preview: ["[math]"],
    //  or        preview: [["img",{src: "http://myserver.com/images/mypic.jpg"}]]
    //  
    preview: "TeX"
    
  },
  

  //============================================================================
  //
  //  These parameters control the HTML-CSS output jax.
  //
  "HTML-CSS": {
    
    //
    //  This controls the global scaling of mathematics as compared to the 
    //  surrounding text.  Values between 100 and 133 are usually good choices.
    //
    scale: 100,
    
    //
    //  This is a list of the fonts to look for on a user's computer in
    //  preference to using MathJax's web-based fonts.  These must
    //  correspond to directories available in the  jax/output/HTML-CSS/fonts
    //  directory, where MathJax stores data about the characters available
    //  in the fonts.  Set this to ["TeX"], for example, to prevent the
    //  use of the STIX fonts, or set it to an empty list, [], if
    //  you want to force MathJax to use web-based or image fonts.
    //
    // availableFonts: ["STIX","TeX"],
    availableFonts: ["TeX"],  // This is important for Mac OS X Lion because broken STIX fonts are installed
    
    //
    //  This is the preferred font to use when more than one of those
    //  listed above is available.
    //
    preferredFont: "TeX",
    
    //
    //  This is the web-based font to use when none of the fonts listed
    //  above are available on the user's computer.  Note that currently
    //  only the TeX font is available in a web-based form.  Set this to
    //  
    //      webFont: null,
    //
    //  if you want to prevent the use of web-based fonts.
    //
    webFont: "TeX",
    
    //
    //  This is the font to use for image fallback mode (when none of the
    //  fonts listed above are available and the browser doesn't support
    //  web-fonts via the @font-face CSS directive).  Note that currently
    //  only the TeX font is available as an image font.  Set this to
    //
    //      imageFont: null,
    //  
    //  if you want to prevent the use of image fonts (e.g., you have not
    //  installed the image fonts on your server).  In this case, only
    //  browsers that support web-based fonts will be able to view your pages
    //  without having the fonts installed on the client computer.  The browsers
    //  that support web-based fonts include: IE6 and later, Chrome, Safari3.1
    //  and above, Firefox3.5 and later, and Opera10 and later.  Note that
    //  Firefox3.0 is NOT on this list, so without image fonts, FF3.0 users
    //  will be required to to download and install either the STIX fonts or the
    //  MathJax TeX fonts.
    //
    imageFont: null,
    
    //
    //  This is the font-family CSS value used for characters that are not
    //  in the selected font (e.g., for web-based fonts, this is where to
    //  look for characters not included in the MathJax_* fonts).  IE will
    //  stop looking after the first font that exists on the system (even
    //  if it doesn't contain the needed character), so order these carefully.
    //  
    undefinedFamily: "STIXGeneral,'Arial Unicode MS',serif",
    
    //
    //  This controls whether the MathJax contextual menu will be available
    //  on the mathematics in the page.  If true, then right-clicking (on
    //  the PC) or control-clicking (on the Mac) will produce a MathJax
    //  menu that allows you to get the source of the mathematics in
    //  various formats, change the size of the mathematics relative to the
    //  surrounding text, and get information about MathJax.
    //  
    //  Set this to false to disable the menu.  When true, the MathMenu 
    //  items below configure the actions of the menu.
    //  
    showMathMenu: true,

  },
  
  
  //============================================================================
  //
  //  These parameters control the MMLorHTML configuration file.
  //  NOTE:  if you add MMLorHTML.js to the config array above,
  //  you must REMOVE the output jax from the jax array.
  //
  MMLorHTML: {
    //
    //  The output jax that is to be preferred when both are possible
    //  (set to "MML" for native MathML, "HTML" for MathJax's HTML-CSS output jax).
    //
    prefer: {
      MSIE:    "MML",
      Firefox: "MML",
      Opera:   "HTML",
      other:   "HTML"
    }
  }
});

MathJax.Ajax.loadComplete("[MathJax]/config/mathjax-xmds.js");
