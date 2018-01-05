#
# Be sure to run `pod lib lint StringStylizer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "PagingKit"
  s.version          = "1.2.2"
  s.summary          = "PagingKit provides customisable menu & content UI."

  s.description      = <<-DESC
    There are many libaries providing "Paging UI" which has menu and content area. They are convinience but not customizable because your app have to make compatible with the library about layout and design. When It doesn't fit the libaries, you need to fork the library or find another one.

    PagingKit has more flexible layout and design than the other libraries. You can construct "Menu" and "Content" UI, and they work together. That's all features this library provides. You can fit layout and design of Pagingin UI to your apps as you like.
                         DESC

  s.homepage         = "https://github.com/kazuhiro4949/PagingKit"
  s.license          = 'MIT'
  s.author           = { "Kazuhiro Hayashi" => "k.hayashi.info@gmail.com" }
  s.source           = { :git => "https://github.com/kazuhiro4949/PagingKit.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = "PagingKit/*"
end
