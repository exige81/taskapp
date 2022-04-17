module.exports = {
  purge: [
    './app/**/*.html.erb',
    './app/helpers/**/*.rb',
    '.app/javascript/**/*.js'
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      backgroundImage: {
        'grid': "url('grid.svg')"
      }
    },
  },
  variants: {
    extend: {},
  },
  plugins: [
    require('@tailwindcss/forms')
  ],
}
